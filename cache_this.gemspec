Gem::Specification.new do |s|
  s.name        = 'cache_this'
  s.version     = '0.0.2'
  s.date        = '2015-06-15'
  s.summary     = 'Cache with element level time expiration'
  s.description = 'This gems allow setting individual expiration date for each cache element'
  s.authors     = ['https://github.com/scicco']
  s.email       = 'guido.scicolone@gmail.com'
  s.files       = %w(lib/cache_this.rb lib/cache/this.rb)
  s.homepage    = 'http://rubygems.org/gems/cache_this'
  s.license     = 'MIT'
  s.add_dependency 'activesupport', '~> 4.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-nc', '~> 0.2.0'
  s.add_development_dependency 'guard', '~> 2.12.6'
  s.add_development_dependency 'guard-rspec', '~> 4.5.2'
  s.add_dependency 'timecop', '~> 0.7.4'
end