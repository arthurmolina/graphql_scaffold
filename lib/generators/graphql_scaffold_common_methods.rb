# frozen_string_literal: true

module GraphqlScaffoldCommonMethods
  private

  def model_exists?
    ActiveRecord::Base.connection.tables.include?(plural_name)
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