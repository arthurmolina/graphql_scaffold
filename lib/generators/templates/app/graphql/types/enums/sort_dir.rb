module Types
  module Enums
    class SortDir < Types::BaseEnum
      description "Column ordering options"
      value("asc", "in the ascending order, nulls last")
      value("asc_nulls_first", "in the ascending order, nulls first")
      value("asc_nulls_last", "in the ascending order, nulls last")
      value("desc", "in the descending order, nulls last")
      value("desc_nulls_first", "in the descending order, nulls first")
      value("desc_nulls_last", "in the descending order, nulls last")
    end
  end
end