# graphql scaffold <img src="https://cloud.githubusercontent.com/assets/2231765/9094460/cb43861e-3b66-11e5-9fbf-71066ff3ab13.png" height="40" alt="graphql-ruby"/>

[![Build Status](https://travis-ci.org/arthurmolina/graphql-ruby.svg?branch=master)](https://travis-ci.org/arthurmolina/graphql_scaffold)
[![Gem Version](https://badge.fury.io/rb/graphql_scaffold.svg)](https://rubygems.org/gems/graphql_scaffold)
[![Code Climate](https://codeclimate.com/github/arthurmolina/graphql_scaffold/badges/gpa.svg)](https://codeclimate.com/github/arthurmolina/graphql_scaffold)
[![Test Coverage](https://codeclimate.com/github/arthurmolina/graphql_scaffold/badges/coverage.svg)](https://codeclimate.com/github/arthurmolina/graphql_scaffold)
[![GitHub](https://img.shields.io/github/license/arthurmolina/graphql_scaffold)]

Rails generator for scaffolding models with [Graphql-Ruby](https://github.com/rmosolgo/graphql-ruby/).

## Installation

Install from RubyGems by adding it to your `Gemfile`, then bundling.

```ruby
# Gemfile
gem 'graphql_scaffold'
```

```
$ bundle install
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
