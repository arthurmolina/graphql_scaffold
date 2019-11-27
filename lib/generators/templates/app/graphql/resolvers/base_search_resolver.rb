# frozen_string_literal: true

module Resolvers
  class BaseSearchResolver
    include SearchObject.module(:graphql)
  	include SearchObject.module(:enum)

    def fetch_results
      return super unless context.present?
      # Authentication here!
      # raise "Not connected or no permission to this query." unless context[:current_user].present?
      super
    end

    # default max limit
    def max_limit
      20
    end

    # default min limit
    def min_limit
      0
    end

    def between(value)
      return value if value < max_limit and value > min_limit
      return max_limit if value >= max_limit
      min_limit if value <= min_limit
    end

    def apply_filter(scope, value)
      where == '()' ? scope : scope.where(query_where(scope, value))
    end

    def escape_search_term(term)
      "%#{term.gsub(/\s+/, '%')}%"
    end

    def query_where(scope, value)
      redefine_values(transform_element(scope, arguments_to_h(value)))
    end

    def arguments_to_h(value)
      if value.is_a? Array
        value.map{ |v| arguments_to_h(v) }
      else
        value.to_h
      end
    end

    def has_comparison?(values)
      values[:field].present? and values[:operator].present? and values[:value].present?
    end

    def transform_element(scope, v, and_or_check = true)
      and_or = and_or_check ? ' and ' : ' or '
      values = v.clone
      return '' if values.nil?
      if values.is_a? Array
        return "(#{values.map{ |v| transform_element(scope, v) }.join(and_or)})"
      elsif values.is_a? Hash
        if values[:_or].present?
          values[:_or].push({field: values[:field], operator: values[:operator], value: values[:value]}) if has_comparison?(values)
          return transform_element(scope, values[:_or], false) 
        elsif values[:_and].present?
          values[:_and].push({field: values[:field], operator: values[:operator], value: values[:value]}) if has_comparison?(values)
          return transform_element(scope, values[:_and], true)
        elsif values[:_not].present?
          addon = has_comparison?(values) ? convert_element(scope, values) + and_or : ''
          res = transform_element(scope, values[:_not], and_or_check)
          return "#{addon}not (#{res.is_a?(String) ? res : res.join(and_or)})"
        else
          return convert_element(scope, values)
        end
      else
        return values
      end
    end

    def change_type(scope, field, value)
      case scope.klass.attribute_types[field].class.to_s
      when 'ActiveModel::Type::Integer'
        value.map(&:to_i)
      when 'ActiveModel::Type::Float'
        value.map(&:to_f)
      when 'ActiveModel::Type::Boolean'
        value.first.downcase == 'true' ? true : false
      else
        value
      end
    end

    def convert_element(scope, values)
      return '' if not has_comparison?(values)
      converted_value = change_type(scope, values[:field], values[:value]).to_json
      values[:field] + case values[:operator]
      when 'equal', 'in'
        " in (<var!>#{converted_value}</var!>)"
      when 'greater_than'
        " > <var!>#{converted_value}</var!>"
      when 'greater_than_or_equal_to'
        " >= <var!>#{converted_value}</var!>"
      when 'ilike'
        " ilike <var!>#{converted_value}</var!>"
      when 'is_null'
        " is #{values[:value].first.downcase == 'true' ? '' : 'not'} null"
      when 'like'
        " like <var!>#{converted_value}</var!>"
      when 'less_than'
        " < <var!>#{converted_value}</var!>"
      when 'less_than_or_equal_to'
        " <= <var!>#{converted_value}</var!>"
      when 'not_equal', 'not_in'
        " not in (<var!>#{converted_value}</var!>)"
      when 'not_ilike'
        " not ilike <var!>#{converted_value}</var!>"
      when 'not_like'
        " not like <var!>#{converted_value}</var!>"
      when 'not_similar'
        " not similar to <var!>#{converted_value}</var!>"
      when 'similar'
        " similar to <var!>#{converted_value}</var!>"
      else
        ''
      end
    end

    def redefine_values(expression)
      values = {}
      variables = expression.scan(/<var!>(.+?)<\/var!>/i).flatten.uniq
      for i in 0..(variables.count-1) do
        values["v#{i}".to_sym] = JSON.parse(variables[i])
        expression = expression.gsub("<var!>#{variables[i]}</var!>", ":v#{i}")
      end
      [expression, values]
    end

    # https://stackoverflow.com/questions/5826210/rails-order-with-nulls-last
    def case_sort(field, sort_direction)
      case sort_direction
      when 'asc'
        "#{field} asc"
      when 'asc_nulls_first'
        "CASE WHEN #{field} IS NOT NULL THEN 1 ELSE 0 END, #{field} ASC"
      when 'asc_nulls_last'
        "CASE WHEN #{field} IS NULL THEN 1 ELSE 0 END, #{field} ASC"
      when 'desc'
        "#{field} desc"
      when 'desc_nulls_first'
        "CASE WHEN #{field} IS NOT NULL THEN 1 ELSE 0 END, #{field} DESC"
      when 'desc_nulls_last'
        "CASE WHEN #{field} IS NULL THEN 1 ELSE 0 END, #{field} DESC"
      else
        ''
      end
    end

  end
end