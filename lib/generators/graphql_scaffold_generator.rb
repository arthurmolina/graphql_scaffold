# frozen_string_literal: true

class GraphqlScaffoldGenerator < Rails::Generators::Base
  require_relative 'graphql_scaffold_common_methods'
  include GraphqlScaffoldCommonMethods

  desc 'This generator scaffolds a Graphql from a table.'

  source_root File.expand_path('../templates', __FILE__)

  argument :model_name, type: :string, desc: 'Name of model (singular)'
  argument :myattributes, type: :array, default: [], banner: 'field:type field:type'

  class_option :namespace, default: nil, desc: 'Create a namespace for the Model and GraphQL.'
  class_option :queries, type: :boolean, default: true, desc: 'Create the GraphQL Queries.'
  class_option :mutations, type: :boolean, default: true, desc: 'Create the GraphQL Mutations.'
  class_option :subscriptions, type: :boolean, default: true, desc: 'Create the GraphQL Subscriptions.'
  class_option :tests, type: :boolean, default: true, desc: 'Create the GraphQL Tests.'

  def check_what_to_do
    if !queries && !mutations && !subscriptions
      puts "\n  ** What do you want me to do? Nothing??? No queries, no mutations, no subscriptions...\n\n"
      exit
    end
  end

  def install_gems
    if check_gem_versions.present?
      puts '='*80
      puts '      ATENTION!!! ATENTION!!! ATENTION!!!'
      puts '='*80
      puts check_gem_versions.join("\n")
      puts '='*80
    end    
  end

  def check_model_existence
    unless model_exists?
      if myattributes.present?
        puts 'Generating model...'
        generate('model', "#{namespace.nil? ? '' : namespace+'::'}#{name} #{myattributes.join(' ')}")
      else
        puts "The model #{name} wasn't found. You can add attributes and generate the model with Graphql Scaffold."
        exit
      end
    end
  end

  def copy_files
    copy_file 'app/graphql/types/date_time_type.rb', 'app/graphql/types/date_time_type.rb'
    # copy_file 'app/graphql/types/base_field.rb', 'app/graphql/types/base_field.rb'

    if queries
      copy_file 'app/graphql/resolvers/base_search_resolver.rb', 'app/graphql/resolvers/base_search_resolver.rb'
      copy_file 'app/graphql/types/enums/operator.rb', 'app/graphql/types/enums/operator.rb'
      copy_file 'app/graphql/types/enums/sort_dir.rb', 'app/graphql/types/enums/sort_dir.rb'
    end

    if mutations
      copy_file 'app/graphql/mutations/base_mutation.rb', 'app/graphql/mutations/base_mutation.rb'
    end

    if subscriptions
    end

    if tests && (queries || mutations || subscriptions)
      copy_file 'test/integration/graphql_1st_test.rb', 'test/integration/graphql_1st_test.rb'
    end
  end

  def generate_graphql_query
    template 'app/graphql/types/enums/table_field.rb', "app/graphql/types/enums/#{plural_name_snaked}_field.rb"
    template 'app/graphql/types/table_type.rb', "app/graphql/types/#{singular_name_snaked}_type.rb"
    
    if queries
      template 'app/graphql/resolvers/table_search.rb', "app/graphql/resolvers/#{plural_name_snaked}_search.rb"
    end

    if mutations
      template 'app/graphql/mutations/change_table.rb', "app/graphql/mutations/change_#{singular_name_snaked}.rb"
      template 'app/graphql/mutations/create_table.rb', "app/graphql/mutations/create_#{singular_name_snaked}.rb"
      template 'app/graphql/mutations/destroy_table.rb', "app/graphql/mutations/destroy_#{singular_name_snaked}.rb"
    end

    if subscriptions
    end

    if tests && (queries || mutations || subscriptions)
      template 'test/integration/graphql_table_test.rb', "test/integration/graphql_#{singular_name_snaked}_test.rb"
    end
  end

  def add_in_query_type
    if queries
      inject_into_file(
        'app/graphql/types/query_type.rb', 
        "    field :#{list_many}, function: Resolvers::#{plural_name_camelized}Search\n", 
        after: "class QueryType < Types::BaseObject\n")
    end

    if mutations
      inject_into_file(
        'app/graphql/types/mutation_type.rb', 
        "\n    field :#{create_one}, mutation: Mutations::Create#{singular_name_camelized}" +
        "\n    field :#{change_one}, mutation: Mutations::Change#{singular_name_camelized}" +
        "\n    field :#{destroy_one}, mutation: Mutations::Destroy#{singular_name_camelized}\n",
        after: "class MutationType < Types::BaseObject\n")
    end
  end

end