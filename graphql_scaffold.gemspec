# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'graphql_scaffold/version'
require 'date'

Gem::Specification.new do |s|
  s.name = 'graphql_scaffold'
  s.version     = GraphqlScaffold::VERSION
  s.date        = Date.today.to_s
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'A good way to automatize graphql models'
  s.authors     = ['Arthur Molina']
  s.email       = ['arthurmolina@gmail.com']
  s.homepage    = 'https://arthurmolina.com'
  s.licenses    = 'MIT'
  s.files       = Dir["{lib}/**/*", "LICENSE", "readme.md"]
  s.require_paths = ['lib', 'lib/generators']
end
