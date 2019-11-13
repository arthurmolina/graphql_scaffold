# frozen_string_literal: true

class Mutations::Change<%= singular_name_camelized %> < Mutations::BaseMutation
  description 'Change a <%= singular_name_camelized %> record'
  #graphql_name 'Change<%= singular_name_camelized %>'

<% for attribute in columns_types -%>
  argument :<%= attribute[:name] %>, <%= attribute[:name] == primary_key ? 'ID' : attribute[:type] %>, required: <%= attribute[:name] == primary_key ? 'true' : 'false' %>
<% end -%>

  field :<%= singular_name_snaked %>, Types::<%= singular_name_camelized %>Type, null: true
  field :errors, [String], null: false

  def resolve(**args)
    <%= singular_name_snaked %> = <%= singular_name_camelized %>.find(args[:id])
    <%= singular_name_snaked %>.update(args)
    return {
      <%= singular_name_snaked %>: <%= singular_name_snaked %>,
      errors: <%= singular_name_snaked %>.errors.full_messages
    }
  rescue ActiveRecord::RecordInvalid => e
    GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
  end
end