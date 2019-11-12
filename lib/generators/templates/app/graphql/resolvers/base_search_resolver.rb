module Resolvers
  class BaseSearchResolver
    include SearchObject.module(:graphql)
  	include SearchObject.module(:enum)

    def escape_search_term(term)
      "%#{term.gsub(/\s+/, '%')}%"
    end

    def query_where(value)
      redefine_values(transform_element(arguments_to_h(value)))
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

    def transform_element(v, and_or_check = true)
      and_or = and_or_check ? ' and ' : ' or '
      values = v.clone
      return '' if values.nil?
      if values.is_a? Array
        return "(#{values.map{ |v| transform_element(v) }.join(and_or)})"
      elsif values.is_a? Hash
        if values[:_or].present?
          values[:_or].push({field: values[:field], operator: values[:operator], value: values[:value]}) if has_comparison?(values)
          return transform_element(values[:_or], false) 
        elsif values[:_and].present?
          values[:_and].push({field: values[:field], operator: values[:operator], value: values[:value]}) if has_comparison?(values)
          return transform_element(values[:_and], true)
        elsif values[:_not].present?
          addon = has_comparison?(values) ? convert_element(values) + and_or : ''
          res = transform_element(values[:_not], and_or_check)
          return "#{addon}not (#{res.is_a?(String) ? res : res.join(and_or)})"
        else
          return convert_element values
        end
      else
        return values
      end
    end

    def convert_element(values)
      return '' if not has_comparison?(values)

      values[:field] + case values[:operator]
      when "equal", "in"
        " in (<var!>#{values[:value].to_json}</var!>)"
      when "greater_than"
        " > <var!>#{values[:value].to_json}</var!>"
      when "greater_than_or_equal_to"
        " >= <var!>#{values[:value].to_json}</var!>"
      when "ilike"
        " ilike <var!>#{values[:value].to_json}</var!>"
      when "is_null"
        " is #{values[:value].downcase == 'true' ? '' : 'not'} null"
      when "like"
        " like <var!>#{values[:value].to_json}</var!>"
      when "less_than"
        " < <var!>#{values[:value].to_json}</var!>"
      when "less_than_or_equal_to"
        " <= <var!>#{values[:value].to_json}</var!>"
      when "not_equal", "not_in"
        " not in (<var!>#{values[:value].to_json}</var!>)"
      when "not_ilike"
        " not ilike <var!>#{values[:value].to_json}</var!>"
      when "not_like"
        " not like <var!>#{values[:value].to_json}</var!>"
      when "not_similar"
        " not similar to <var!>#{values[:value].to_json}</var!>"
      when "similar"
        " similar to <var!>#{values[:value].to_json}</var!>"
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

  end
end