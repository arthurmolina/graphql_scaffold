module Types
  module Enums
    class <%= plural_name_camelized %>Field < Types::BaseEnum
      description 'Fields from table <%= plural_name %>''
<% for attribute in columns_types -%>
      value("<%= attribute[:name] %>")
<% end -%>
    end
  end
end