module Types
  module Enums
    class Operator < Types::BaseEnum
      description 'Comparison Operators'
      value('equal', 'Equal')
      value('greater_than', 'Greater than')
      value('greater_than_or_equal_to', 'Greater than or equal')
      value('ilike', 'Case insensitive Text search')
      value('in', 'In list')
      value('is_null', 'Is Null')
      value('like', 'Case sensitive Text search')
      value('less_than',  'Less than')
      value('less_than_or_equal_to', 'Less than or equal')
      value('not_equal', 'Not Equal')
      value('not_ilike', 'Case insensitive Text search negative')
      value('not_in', 'Not in list')
      value('not_like', 'Case sensitive Text search negative')
      value('not_similar', 'Not Similar to Regular Expressions')
      value('similar', 'Similar to Regular Expressions')
    end
  end
end
