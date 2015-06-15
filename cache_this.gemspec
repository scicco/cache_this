Gem::Specification.new do |s|
  s.name        = 'cache_this'
  s.version     = '0.0.1'
  s.date        = '2015-06-08'
  s.summary     = 'Cache with element level time expiration'
  s.description = 'This gems allow setting individual expiration date for each cache element'
  s.authors     = ['https://github.com/scicco']
  s.email       = 'guido.scicolone@gmail.com'
  s.files       = %w(lib/cache_this.rb lib/cache/this.rb)
  s.homepage    = 'http://rubygems.org/gems/cache_this'
  s.license     = 'MIT'
  s.add_dependency 'activesupport', '~> 4.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-nc'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_dependency 'timecop'
end