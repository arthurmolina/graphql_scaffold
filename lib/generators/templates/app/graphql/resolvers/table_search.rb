require 'search_object/plugin/graphql'

class Resolvers::<%= plural_name_camelized %>Search < Resolvers::BaseSearchResolver

  # scope is starting point for search
  scope { <%= model_name %>.all }

  type types[Types::<%= singular_name_camelized %>Type]

  ### Pagination
  option :first, type: types.Int, with: :apply_first
  option :skip, type: types.Int, with: :apply_skip

  def apply_first(scope, value)
    scope.limit(value)
  end

  def apply_skip(scope, value)
    scope.offset(value)
  end

  ### Order by
  class <%= plural_name_camelized %>OrderBy < ::Types::BaseInputObject
    argument :field, Types::Enums::<%= plural_name_camelized %>Field, required: false
    argument :sortDirection, Types::Enums::SortDir, required: false
  end

  option :sort_by, type: types[<%= plural_name_camelized %>OrderBy], with: :apply_sort_by

  def apply_sort_by(scope, value)
    scope.order( value.map{|arg| 
      Types::Enums::<%= plural_name_camelized %>Field.values.include?(arg[:field]) ? case_sort(arg[:field], arg[:sort_direction]) : ''
    }.join(', ') )
  end


  ### Distinct
  option :distinct_on, type: types[Types::Enums::<%= plural_name_camelized %>Field], with: :apply_distinct_on

  def apply_distinct_on(scope, value)
    scope.select("distinct on (#{value.uniq.join(', ')}) *")
  end


  ### Booleans
<% for attribute in columns_types -%>
<% if attribute[:type] == 'Boolean' -%>
  option(:<%= attribute[:name] %>, type: types.Boolean, description: 'Filter for <%= attribute[:name] %>') { |scope, value| scope.where(<%= attribute[:name] %>: value)}
<% end -%>
<% end -%>

  ### Filter
  class <%= plural_name_camelized %>WhereExp < ::Types::BaseInputObject
    argument :_or, [self], required: false
    argument :_and, [self], required: false
    argument :_not, [self], required: false
    argument :field, Types::Enums::<%= plural_name_camelized %>Field, required: false
    argument :operator, Types::Enums::Operator, required: false
    argument :value, [String], required: false
  end

  option :where, type: types[<%= plural_name_camelized %>WhereExp], with: :apply_filter

  def apply_filter(scope, value)
    where == '()' ? scope : scope.where(query_where(value))
  end

end