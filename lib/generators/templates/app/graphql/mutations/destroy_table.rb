# frozen_string_literal: true

class Mutations::Destroy<%= singular_name_camelized %> < Mutations::BaseMutation
  description 'Destroy a <%= singular_name_camelized %> record'
  #graphql_name 'Destroy<%= singular_name_camelized %>'

  argument :<%= primary_key %>, ID, required: true

  field :<%= singular_name_snaked %>, Types::<%= singular_name_camelized %>Type, null: true
  field :errors, [String], null: false

  def resolve(**args)
    <%= singular_name_snaked %> = <%= singular_name_camelized %>.find(args[:<%= primary_key %>])
    <%= singular_name_snaked %>.destroy
    return {
      <%= singular_name_snaked %>: <%= singular_name_snaked %>,
      errors: <%= singular_name_snaked %>.errors.full_messages
    }
  rescue ActiveRecord::RecordInvalid => e
    GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
  end
end