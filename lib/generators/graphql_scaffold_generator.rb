# frozen_string_literal: true

class GraphqlScaffoldGenerator < Rails::Generators::Base
  require_relative 'graphql_scaffold_common_methods'
  include GraphqlScaffoldCommonMethods

  desc 'This generator scaffolds a Graphql from a table.'

  source_root File.expand_path('../templates', __FILE__)

  argument :name, type: :string, desc: 'Name of model (singular)'
  argument :myattributes, type: :array, default: [], banner: 'field:type field:type'

  class_option :namespace, default: nil
  class_option :donttouchgem, default: nil
  class_option :mountable_engine, default: true

  def check_model_existence
    unless model_exists?
      if myattributes.present?
        puts 'Generating model...'
        generate('model', "#{name} #{myattributes.join(' ')}")
      else
        puts "The model #{name} wasn't found. You can add attributes and generate the model with Graphql Scaffold."
        exit
      end
    end
  end

  def install_gems
    require_gems if options[:donttouchgem].blank?

    Bundler.with_clean_env do
      run 'bundle install'
    end

    if options[:donttouchgem].blank?
      generate('graphql:install')
      run 'bundle install'
    end
  end

  def copy_files
    copy_file 'app/graphql/resolvers/base_search_resolver.rb', 'app/graphql/resolvers/base_search_resolver.rb'
    copy_file 'app/graphql/types/enums/operator.rb', 'app/graphql/types/enums/operator.rb'
    copy_file 'app/graphql/types/enums/sort_dir.rb', 'app/graphql/types/enums/sort_dir.rb'
    copy_file 'app/graphql/types/date_time_type.rb', 'app/graphql/types/date_time_type.rb'
    copy_file 'app/graphql/types/base_field.rb', 'app/graphql/types/base_field.rb'
    copy_file 'app/graphql/mutations/base_mutation.rb', 'app/graphql/mutations/base_mutation.rb'
    copy_file 'test/integration/graphql_1st_test.rb', 'test/integration/graphql_1st_test.rb'
  end

  def generate_graphql_query
    template 'app/graphql/types/enums/table_field.rb', "app/graphql/types/enums/#{plural_name_snaked}_field.rb"
    template 'app/graphql/types/table_type.rb', "app/graphql/types/#{singular_name_snaked}_type.rb"
    template 'app/graphql/resolvers/table_search.rb', "app/graphql/resolvers/#{plural_name_snaked}_search.rb"
    template 'app/graphql/mutations/change_table.rb', "app/graphql/mutations/change_#{singular_name_snaked}.rb"
    template 'app/graphql/mutations/create_table.rb', "app/graphql/mutations/create_#{singular_name_snaked}.rb"
    template 'app/graphql/mutations/destroy_table.rb', "app/graphql/mutations/destroy_#{singular_name_snaked}.rb"
    template 'test/integration/graphql_table_test.rb', "test/integration/graphql_#{singular_name_snaked}_test.rb"
  end

  def add_in_query_type
    inject_into_file(
      'app/graphql/types/query_type.rb', 
      "    field :#{list_many}, function: Resolvers::#{plural_name_camelized}Search\n", 
      after: "class QueryType < Types::BaseObject\n")

    inject_into_file(
      'app/graphql/types/mutation_type.rb', 
      "\n    field :#{create_one}, mutation: Mutations::Create#{singular_name_camelized}" +
      "\n    field :#{change_one}, mutation: Mutations::Change#{singular_name_camelized}" +
      "\n    field :#{destroy_one}, mutation: Mutations::Destroy#{singular_name_camelized}\n",
      after: "class MutationType < Types::BaseObject\n")
  end

end