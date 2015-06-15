require 'active_support/duration'
require 'active_support/time'

module Cache
  class This
    def initialize(*args)
      expiration, _ = args
      expiration ||= lambda { 1.hour.from_now }
      @expiration = expiration
      @cache_values ||= {}
      @cache_timeouts ||= {}
      #test = 13wr
      @timeout_suffix ||= ''
    end

    def get_or_set(name, timeout = nil, value = nil, &block)
      cached_value = get_value(name, timeout, value, &block)
      cached_value ||= value
      set_value(name, cached_value, &block) if expired?(name)
      add_expiration(name, timeout) if expired?(name)
      get(name)
    end

    def get(name)
      get_value(name, nil, nil)
    end

    def fetch(name, &block)
      result = get(name)
      if result.nil? and block_given?
        result = yield block
      end
      result
    end

    def delete(name)
      @cache_timeouts.delete(timeout_key_name(name))
      @cache_values.delete(name.to_sym)
    end
    alias_method :evict, :delete

    def clear
      @cache_values = {}
      @cache_timeouts = {}
      nil
    end

    def to_a
      result = []
      @cache_values.keys.each_with_index do |name, index|
        element = [name.to_sym, get(name), timeout_for(name)]
        result[index] = element
      end
      #TODO: optionally sort this by timeout
      result
    end

    def key?(name)
      @cache_values.has_key?(name.to_sym) and @cache_timeouts.has_key?(timeout_key_name(name).to_sym)
    end
    alias_method :has_key?, :key?

    def count
      @cache_values.keys.size
    end
    alias_method :size, :count

    #complete eviction before enabled these
    #def values
    #  @cache_values
    #end
    #
    #def timers
    #  @cache_timeouts
    #end

    protected

    def add_expiration(name, timeout = nil)
      timeout_value = timeout.call if timeout.present? and timeout.respond_to?(:call)
      timeout_value ||= Time.now + timeout.seconds if timeout.present? and timeout.is_a?(Fixnum)
      timeout_value ||= @expiration.call if @expiration.lambda?
      timeout_value ||= @expiration.send(:seconds).from_now
      set_timeout_for(name, timeout_value)
    end

    def set_value(name, value, &block)
      if block_given?
        result = yield block
      else
        result = value.call if value.present? and value.respond_to?(:call)
        result ||= value
      end
      set_value_for(name, result)
      result
    end

    def get_value(name, timeout, value = nil, &block)
      timeout_value = timeout_for(name)
      if timeout_value.nil? or expired?(name)
        return nil
      end
      value_for(name.to_sym)
    end

    def timeout_key_name(name)
      (name.to_s + @timeout_suffix.to_s).to_sym
    end

    def timeout_for(name)
      @cache_timeouts[timeout_key_name(name)]
    end

    def value_for(name)
      @cache_values[name.to_sym]
    end

    def set_value_for(name, value)
      @cache_values[name.to_sym] = value
      @cache_values[name.to_sym]
    end

    def set_timeout_for(name, value)
      timeout_name = timeout_key_name(name)
      @cache_timeouts[timeout_name] = value
      @cache_timeouts[timeout_name]
    end

    def expired?(name)
      timer_name = timeout_key_name(name)
      timer_value = @cache_timeouts[timer_name]
      return true if timer_value.nil?
      timer_value < Time.now
    end
  end
end