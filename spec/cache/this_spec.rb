require 'spec_helper'

describe Cache::This do
  let(:cache) { Cache::This.new }
  let(:cache1hour) { Cache::This.new }
  let(:cache10minutes) { Cache::This.new(lambda { 10.minutes.from_now }) }

  after(:each) do
    cache1hour.clear
    cache.clear
    cache10minutes.clear
    Timecop.return
  end

  describe 'the timeout argument is working' do
    before(:each) do
      expect(cache1hour.size).to eq(0)
    end

    it 'when a nil value is passed' do
      Timecop.freeze(Time.now)
      cache1hour.get_or_set('test1', nil, lambda { 'my test' })
      expect(cache1hour.size).to eq(1)
      expect(cache1hour.instance_variable_get(:@cache_values)[:test1]).to eq('my test')
      expect(cache1hour.instance_variable_get(:@cache_timeouts)[:test1]).not_to eq(Time.now)
      expect(cache1hour.instance_variable_get(:@cache_timeouts)[:test1]).to eq(60.minutes.from_now)
    end

    it 'when a specific time value is passed' do
      Timecop.freeze(Time.now)
      cache.get_or_set('test2', lambda { Time.now + 10.minutes }, lambda { 'my test' })
      expect(cache.size).to eq(1)
      expect(cache.instance_variable_get(:@cache_values)[:test2]).to eq('my test')
      expect(cache.instance_variable_get(:@cache_timeouts)[:test2]).not_to eq(Time.now)
      expect(cache.instance_variable_get(:@cache_timeouts)[:test2]).to eq(10.minutes.from_now)
    end

    it 'when a range is passed' do
      Timecop.freeze(Time.now)
      cache.get_or_set('test3', 600, lambda { 'my test' })
      expect(cache.size).to eq(1)
      expect(cache.instance_variable_get(:@cache_values)[:test3]).to eq('my test')
      expect(cache.instance_variable_get(:@cache_timeouts)[:test3]).not_to eq(Time.now)
      expect(cache.instance_variable_get(:@cache_timeouts)[:test3]).to eq(Time.now + 600)
    end
  end

  describe 'a new insert WITH a 10 minutes timeout passed as argument will' do
    before(:each) do
      Timecop.freeze(Time.now)
      expect(cache.size).to eq(0)
      cache.get_or_set('test1', lambda { 10.minutes.from_now }, lambda { 'my test' })
      expect(cache.size).to eq(1)
    end

    it 'add a new element into @cache_values' do
      expect(cache.size).to eq(1)
      expect(cache.instance_variable_get(:@cache_values)[:test1]).to eq('my test')
      expect(cache.has_key?('test1')).to eq(true)
      expect(cache.get('test1')).to eq('my test')
      expect(cache.fetch('test1')).to eq('my test')
    end

    it 'add a new element into @cache_timeouts' do
      expect(cache.size).to eq(1)
      expect(cache.instance_variable_get(:@cache_timeouts)[:test1]).not_to eq(nil)
    end

    it 'set the new timeout to be 10 minutes after now' do
      expect(cache.instance_variable_get(:@cache_timeouts)[:test1]).not_to eq(Time.now)
      expect(cache.instance_variable_get(:@cache_timeouts)[:test1]).to eq(10.minutes.from_now)
    end
  end


  describe 'a new insert WITHOUT timeout passed as argument will' do
    before(:each) do
      Timecop.freeze(Time.now)
      expect(cache.size).to eq(0)
      cache.get_or_set('test1', nil, lambda { 'my test' })
      expect(cache.size).to eq(1)
    end

    it 'add a new element into @cache_values' do
      expect(cache.size).to eq(1)
      expect(cache.instance_variable_get(:@cache_values)[:test1]).to eq('my test')
      expect(cache.has_key?('test1')).to eq(true)
      expect(cache.get('test1')).to eq('my test')
      expect(cache.fetch('test1')).to eq('my test')
    end

    it 'add a new element into @cache_timeouts' do
      expect(cache.size).to eq(1)
      expect(cache.instance_variable_get(:@cache_timeouts)[:test1]).not_to eq(nil)
    end

    it 'the new timeout is 1 hour after now' do
      expect(cache.instance_variable_get(:@cache_timeouts)[:test1]).not_to eq(Time.now)
      expect(cache.instance_variable_get(:@cache_timeouts)[:test1]).to eq(60.minutes.from_now)
    end
  end

  describe 'get_or_set(name, timeout = nil, value = nil, &block)' do
    before(:each) do
      Timecop.freeze(Time.now)
      expect(cache.size).to eq(0)
      cache.get_or_set('test1', nil, lambda { 'my test' })
      expect(cache.size).to eq(1)
    end

    it 'add one element successfully' do
      expect(cache.size).to eq(1)
      expect(cache.get('test1')).to eq('my test')
      expect(cache.has_key?('test1')).to eq(true)
      expect(cache.fetch('test1')).to eq('my test')
      expect(cache.size).to eq(1)
    end

    it 'the new cached element is not nil' do
      element = cache.get('test1')
      expect(element).not_to eq(nil)
    end

    it 'after expiration a new method call returns a not nil value' do
      Timecop.travel(Time.now + 3700)
      element = cache.get_or_set('test1', nil, lambda { 'first test' })
      expect(element).not_to eq(nil)
      expect(cache.has_key?('test1')).to eq(true)
      expect(cache.fetch('test1')).to eq('first test')
    end
  end

  describe 'get(name)' do
    before(:each) do
      Timecop.freeze(Time.now)
      expect(cache.size).to eq(0)
      cache.get_or_set('test get', nil, lambda { 'my get test' })
      expect(cache.size).to eq(1)
    end

    it 'return a previously set value' do
      expect(cache.size).to eq(1)
      expect(cache.get('test get')).to eq('my get test')
      expect(cache.size).to eq(1)
    end

    it 'return nil after expiration' do
      new_time = 2.hours.from_now
      Timecop.travel(new_time)
      #will be zero when eviction is complete
      #expect(cache.size).to eq(0)
      expect(cache.get('test get')).to eq(nil)
    end
  end

  describe 'fetch(name, &block)' do
    before(:each) do
      expect(cache.size).to eq(0)
      cache.get_or_set('test get', nil, lambda { 'my get test' })
      expect(cache.size).to eq(1)
    end

    it 'return the value if existing' do
      expect(cache.fetch('test get')).to eq('my get test')
    end

    it 'return value even if block is passed' do
      expect(cache.fetch('test get') do
        'hello'
      end).to eq('my get test')
    end

    it 'return nil if no block is passed' do
      expect(cache.fetch('not existing')).to eql(nil)
    end

    it 'execute block if value is not existing' do
      expect(cache.fetch('not existing') do
        'hello'
      end).to eq('hello')
    end
  end

  describe 'delete(name)|evict(name)' do
    before(:each) do
      expect(cache.size).to eq(0)
      cache.get_or_set('test delete', nil, lambda { 'my get test' })
      expect(cache.size).to eq(1)
    end

    it 'return the value if element is deleted' do
      expect(cache.delete('test delete')).to eq('my get test')
    end

    it 'return nil if element is not found' do
      expect(cache.delete('not existing')).to eq(nil)
    end

    it 'remove the element from @cache_timeouts and @cache_values' do
      expect(cache.delete('test delete')).to eq('my get test')
      expect(cache.instance_variable_get(:@cache_timeouts)[:test1]).to eq(nil)
      expect(cache.instance_variable_get(:@cache_values)[:test1]).to eq(nil)
    end
  end

  describe 'clear' do
    before(:each) do
      expect(cache.size).to eq(0)
      cache.get_or_set('test clear1', nil, lambda { 'my test 1' })
      cache.get_or_set('test clear2', nil, lambda { 'my test 2' })
      cache.get_or_set('test clear3', nil, lambda { 'my test 3' })
      expect(cache.size).to eq(3)
    end

    it 'remove all elements from @cache_timeouts and @cache_values' do
      expect(cache.clear).to eq(nil)
      expect(cache.instance_variable_get(:@cache_timeouts).size).to eq(0)
      expect(cache.instance_variable_get(:@cache_values).size).to eq(0)
      expect(cache.size).to eq(0)
    end
  end

  describe 'to_a' do
    before(:each) do
      expect(cache.size).to eq(0)
      cache.get_or_set('test to_a1', nil, lambda { 'my test 1' })
      cache.get_or_set('test to_a2', nil, lambda { 'my test 2' })
      cache.get_or_set('test to_a3', nil, lambda { 'my test 3' })
      expect(cache.size).to eq(3)
    end

    it 'return all values as array' do
      expect(cache.to_a.size).to eq(3)
    end
  end

  describe 'key?(name)|has_key?(name)' do
    before(:each) do
      expect(cache.size).to eq(0)
      cache.get_or_set('test get', nil, lambda { 'my get test' })
      expect(cache.size).to eq(1)
    end

    it 'return true for an existing value' do
      expect(cache.size).to eq(1)
      expect(cache.key?('test get')).to eq(true)
      expect(cache.has_key?('test get')).to eq(true)
      expect(cache.size).to eq(1)
    end

    it 'return false for a not-existing value' do
      expect(cache.key?('not existing')).to eq(false)
      expect(cache.has_key?('not existing')).to eq(false)
    end
  end

  describe 'count|size' do
    before(:each) do
      expect(cache.size).to eq(0)
      cache.get_or_set('size1', nil, lambda { 'my test 1' })
      cache.get_or_set('size2', nil, lambda { 'my test 2' })
      cache.get_or_set('size3', nil, lambda { 'my test 3' })
      cache.get_or_set('size4', nil, lambda { 'my test 4' })
      cache.get_or_set('size5', nil, lambda { 'my test 5' })
    end

    it 'return the number of elements of cache' do
      expect(cache.size).to eq(5)
      expect(cache.count).to eq(5)
    end
  end


end