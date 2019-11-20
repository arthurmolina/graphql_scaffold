# frozen_string_literal: true

module GraphqlScaffoldCommonMethods
  private

  def model_exists?
    ActiveRecord::Base.connection.tables.include?(plural_name)
  end

  def name
    "#{namespace.nil? ? '' : 'namespace' + ' '}#{model_name}"
  end

  def singular_name
    name.underscore.singularize
  end

  def singular_name_snaked
    singular_name.gsub(' ', '_')
  end

  def singular_name_camelized
    singular_name_snaked.camelcase
  end

  def plural_name
    name.underscore.pluralize
  end

  def plural_name_snaked
    plural_name.gsub(' ', '_')
  end

  def plural_name_camelized
    plural_name_snaked.camelcase
  end

  def list_many
    "all_#{plural_name_snaked}"
  end

  def list_one
    singular_name_snaked
  end

  def create_one
    "create_#{singular_name_snaked}"
  end

  def change_one
    "change_#{singular_name_snaked}"
  end

  def destroy_one
    "destroy_#{singular_name_snaked}"
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

  def columns_type_without_primary_key
    columns_types.select{|c| !c[:name].in?([primary_key, 'created_at', 'updated_at']) }
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
    model.columns_hash.map{|k,v| {name: k, type: type(v.type), null: v.null, sample: sample(v.type)}}
  end

  def columns_myattributes
    res = [{name: 'id', type: type(:integer), null: false}]
    res = res + myattributes.map{|element|
      div = element.split(':')
      type_defined = div[1].present? ? div[1].split('{')[0] : :string
      {name: div[0], type: type(type_defined), null: false, sample: sample(type_defined)}
    } 
    res << {name: 'created_at', type: type(:datetime), null: false, sample: sample(:datetime)}
    res << {name: 'updated_at', type: type(:datetime), null: false, sample: sample(:datetime)}
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

  def sample(the_type)
    case the_type.to_s.downcase
    when 'datetime'
      Time.now.strftime("%d/%m/%Y %H:%M:%S")
    when 'references', 'integer', 'float'
      rand(1..10).to_s
    else
      the_type.to_s.titlecase
    end
  end

  def queries
    options['queries']
  end

  def mutations
    options['mutations']
  end

  def subscriptions
    options['subscriptions']
  end

  def tests
    options['tests']
  end

  def required_gems
    # {
    #   'graphql' => '1.9.15',
    #   'search_object' => '1.2.3',
    #   'search_object_graphql' => '0.3'
    # }
    [
      {name: 'graphql', version: '1.9.15'},
      {name: 'search_object', version: '1.2.3'},
      {name: 'search_object_graphql', version: '0.3'}
    ]
  end

  def check_gem_versions
    required_gems.map{ |gem_item|
      if Gem.loaded_specs[gem_item[:name]].nil?
        "This version of Graphql Scaffold requires the gem #{gem_item[:name]}, version #{gem_item[:version]}. Please add the following line in your Gemfile:\n\n  gem '#{gem_item[:name]}', '#{version}'\n"
      elsif (Gem.loaded_specs[gem_item[:name]].version <=> Gem::Version.new(gem_item[:version])) < 0 
        "The version of the gem #{gem_item[:name]} is not compatible with this version of Graphql Scaffold. We need at least version #{gem_item[:version]}."
      else
        nil
      end
    }.compact
  end

  def require_gems
    if !Dir.glob('./*.gemspec').empty?
      puts "============> Engine : You must add gems to your main app \n #{required_gems.to_a.map{ |a| "gem '#{a[0]}'#{(a[1].nil? ? '' : ", '#{a[1]}'")} " }.join("\n")}"
    end

    required_gems.each{ |gem_to_add, version|
      gem(gem_to_add, version)
    }
  end
end
