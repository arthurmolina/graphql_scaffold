# encoding : utf-8
#require 'rails_generator/generators/components/scaffold/scaffold_generator'

class GraphqlScaffoldGenerator < Rails::Generators::Base
  desc "This generator scaffolds a Graphql from a table."

  source_root File.expand_path('../templates', __FILE__)

  argument :name, type: :string, desc: "Name of model (singular)"
  argument :myattributes, type: :array, default: [], banner: "field:type field:type"

  class_option :namespace, default: nil
  class_option :donttouchgem, default: nil
  class_option :mountable_engine, default: true

  def check_model_existence
    if !model_exists?
      if myattributes.present?
        puts "Generating model..."
        generate("model", "#{name} #{myattributes.join(' ')}")
      else
        puts "The model #{name} wasn't found. You can add attributes and generate the model with Graphql Scaffold."
        exit
      end
    end
  end

  def install_gems
    return true
    if options[:donttouchgem].blank? then
      require_gems
    end

    Bundler.with_clean_env do
      run "bundle install"
    end

    if options[:donttouchgem].blank? then
      generate("graphql:install")
      run "bundle install"
    end
  end

  def copy_files
    copy_file "app/graphql/resolvers/base_search_resolver.rb", "app/graphql/resolvers/base_search_resolver.rb"
    copy_file "app/graphql/types/enums/operator.rb", "app/graphql/types/enums/operator.rb"
    copy_file "app/graphql/types/enums/sort_dir.rb", "app/graphql/types/enums/sort_dir.rb"
    copy_file "app/graphql/types/date_time_type.rb", "app/graphql/types/date_time_type.rb"
  end

  def generate_graphql_query
    template "app/graphql/types/enums/table_field.rb", "app/graphql/types/enums/#{plural_name}_field.rb"
    template "app/graphql/types/table_type.rb", "app/graphql/types/#{singular_name}_type.rb"
    template "app/graphql/resolvers/table_search.rb", "app/graphql/resolvers/#{plural_name}_search.rb"
  end

  def add_in_query_type
    inject_into_file "app/graphql/types/query_type.rb", "    field :all_#{plural_name}, function: Resolvers::#{plural_name_camelized}Search\n", after: "class QueryType < Types::BaseObject\n"
  end

  private

  #########################################################################################################
  # Common Methods

  def model_exists?
    ActiveRecord::Base.connection.tables.include?(plural_name)
  end

  def singular_name
    name.underscore.singularize
  end

  def single_name_camelized
    singular_name.gsub(' ', '_').camelcase
  end

  def plural_name
    name.underscore.pluralize
  end

  def plural_name_camelized
    plural_name.gsub(' ', '_').camelcase
  end

  def model_name
    name.gsub('_', ' ').titlecase.gsub(' ', '')
  end

  def model
    (eval model_name)
  end

  def primary_key
    if model_exists?
      model.primary_key
    else
      'id'
    end
  end

  def columns_types
    if model_exists?
      if myattributes.present?
        columns_model.select{ |elem|
          columns_myattributes.select{ |el| elem[:name] == el[:name]}.present?
        } 
      else
        columns_model
      end
    else
      columns_myattributes
    end
  end

  def columns_model
    model.columns_hash.map{|k,v| {name: k, type: type(v.type), null: v.null}}
  end

  def columns_myattributes
    res = [{name: 'id', type: type(:integer), null: false}]
    res = res + myattributes.map{|element|
      div = element.split(':')
      type_defined = div[1].present? ? div[1].split('{')[0] : :string
      {name: div[0], type: type(type_defined), null: false}
    } 
    res << {name: 'created_at', type: type(:datetime), null: false}
    res << {name: 'updated_at', type: type(:datetime), null: false}
  end

  def type(the_type)
    case the_type
    when :datetime
      'Types::DateTimeType'
    when 'references'
      'Integer'
    else
      the_type.to_s.titlecase
    end
  end

  def require_gems
    gems = {
      'graphql' => '1.8.13',
      'search_object' => '1.2.0',
      'search_object_graphql' => '0.1'
    }

    if !Dir.glob('./*.gemspec').empty?
      puts "============> Engine : You must add gems to your main app \n #{gems.to_a.map{ |a| "gem '#{a[0]}'#{(a[1].nil? ? '' : ", '#{a[1]}'")} " }.join("\n")}"
    end

    gems.each{ |gem_to_add, version|
      gem(gem_to_add, version)
    }
  end

end