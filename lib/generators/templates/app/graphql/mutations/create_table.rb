# frozen_string_literal: true

class Mutations::Create<%= singular_name_camelized %> < Mutations::BaseMutation
  null true
  description 'Create a <%= singular_name_camelized %> record'
  #graphql_name 'Create<%= singular_name_camelized %>'

<% for attribute in columns_types
  next if attribute[:name] == primary_key
 -%>
  argument :<%= attribute[:name] %>, <%= attribute[:type] %>, required: false
<% end -%>

  field :<%= singular_name_snaked %>, Types::<%= singular_name_camelized %>Type, null: true
  field :errors, [String], null: false

  def resolve(**args)
    <%= singular_name_snaked %> = <%= singular_name_camelized %>.new(args)
    if <%= singular_name_snaked %>.save
      return {
        <%= singular_name_snaked %>: <%= singular_name_snaked %>,
        errors: []
      }
    else
      return {
        <%= singular_name_snaked %>: nil,
        errors: <%= singular_name_snaked %>.errors.full_messages
      }
    end
  rescue ActiveRecord::RecordInvalid => e
    GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
  end
end