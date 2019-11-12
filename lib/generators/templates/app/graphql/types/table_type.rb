class Types::<%= single_name_camelized %>Type < Types::BaseObject
<% for attribute in columns_types -%>
  field :<%= attribute[:name] %>, <%= attribute[:name] == primary_key ? 'ID' : attribute[:type] %>, null: <%= attribute[:null] %>
<% end -%>
end