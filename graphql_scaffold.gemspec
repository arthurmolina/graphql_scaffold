# frozen_string_literal: true

$:.push File.expand_path('lib', __FILE__)

Gem::Specification.new do |s|
  s.name = 'graphql_scaffold'
  s.version     = '0.0.1'
  s.date        = '2019-11-08'
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'A good way to automatize graphql models'
  s.authors     = ['Arthur Molina']
  s.email       = 'arthurmolina@gmail.com'
  s.homepage    = 'https://arthurmolina.com'
  s.licenses    = ['MIT']
  s.files       = `git ls-files`.split('\n')
  s.require_paths = ['lib', 'lib/generators']
end
