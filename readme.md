# graphql scaffold <img src="https://cloud.githubusercontent.com/assets/2231765/9094460/cb43861e-3b66-11e5-9fbf-71066ff3ab13.png" height="40" alt="graphql-ruby"/>

[![Build Status](https://travis-ci.org/arthurmolina/graphql-ruby.svg?branch=master)](https://travis-ci.org/arthurmolina/graphql_scaffold)
[![Gem Version](https://badge.fury.io/rb/graphql_scaffold.svg)](https://rubygems.org/gems/graphql_scaffold)
[![GitHub](https://img.shields.io/github/license/arthurmolina/graphql_scaffold)](https://img.shields.io/github/license/arthurmolina/graphql_scaffold)

Rails generator for scaffolding models with [GraphQL-Ruby](https://github.com/rmosolgo/graphql-ruby/).

## Installation

Install from RubyGems by adding it to your `Gemfile`:

```ruby
# Gemfile
gem 'graphql_scaffold'
```
And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install graphql_scaffold
```

## Dependencies

The scaffolded graphql queries, mutations and subscriptions depend on:

- `SearchObjectGraphql` >= 0.3
- `SearchObject` >= 1.2.3
- `Graphql` >= 1.9.5

Besides this you may need to run the following command to begin with Graphql:

```
$ rails generate graphql:install
```


## Usage

If you have a model already created:

```
$ rails generate graphql_scaffold model_example
```

If you want to create a model and scaffold your Graphql API:

```
$ rails generate graphql_scaffold model_example field1 field2:integer field3
```

After this, you may need to run `rails db:migrate`. The format for fields are the same as rails generate model.

### Example

## Todo

- Create subscription scaffold
- Better tests

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Run the tests (`rake`)
6. Create new Pull Request

## License

**[MIT License](https://github.com/arthurmolina/graphql_scaffold/blob/master/LICENSE)**


