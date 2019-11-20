require 'test_helper'

class Graphql<%= plural_name_camelized %>Test < ActionDispatch::IntegrationTest
  setup do
    @<%= singular_name_snaked %> = <%= plural_name_snaked %>(:one)
  end

  test "can see a result" do
    gql = <<-GRAPHQL
      {
        <%= list_many_camelized(:lower) %>(first: 10, sort_by: {field: <%= columns_type_without_primary_key.sample[:name] %>, sortDirection: asc}) {
<% for attribute in columns_types -%>
            <%= attribute[:name].camelcase(:lower) %>
<% end -%>
        }
      }
    GRAPHQL

    post '/graphql', params: {query: gql}
    assert_response :success
    json = JSON.parse(response.body)
    assert_not_empty json['data']
    assert_not_empty json['data']['<%= list_many_camelized(:lower) %>']
  end

  test "can add a record" do
    gql = <<-GRAPHQL
      mutation a {
        <%= create_one_camelized(:lower) %>(input: {
<% for attribute in columns_type_without_primary_key -%>
          <%= attribute[:name].camelcase(:lower) %>: <%= attribute[:sample] %>,
<% end -%>
          clientMutationId: "test-1"
        } ) 
        {
          <%= singular_name_camelized(:lower) %> {
<% for attribute in columns_types -%>
            <%= attribute[:name].camelcase(:lower) %>
<% end -%>
          }
          clientMutationId
          errors
        }
      }
    GRAPHQL
    post '/graphql', params: {query: gql}
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_not_empty json['data']
    assert_not_empty json['data']['<%= create_one_camelized(:lower) %>']
    assert_not_empty json['data']['<%= create_one_camelized(:lower) %>']['<%= singular_name_camelized(:lower) %>']
    assert_equal json['data']['<%= create_one_camelized(:lower) %>']['errors'], []

    <%= primary_key %> = json['data']['<%= create_one_camelized(:lower) %>']['<%= singular_name_camelized(:lower) %>']['<%= primary_key.camelcase(:lower) %>']
    assert_not_empty <%= singular_name_camelized %>.where(<%= primary_key %>: <%= primary_key %>)
  end

  test "can change a record" do
    <%= primary_key %> = <%= singular_name_camelized %>.last.<%= primary_key %>
    gql = <<-GRAPHQL
      mutation a {
        <%= change_one_camelized(:lower) %>(input: {
          <%= primary_key.camelcase(:lower) %>: "#{<%= primary_key %>}", 
<% for attribute in columns_type_without_primary_key -%>
          <%= attribute[:name].camelcase(:lower) %>: <%= attribute[:sample] %>,
<% end -%>
          clientMutationId: "test-2"} ) 
        {
          <%= singular_name_camelized(:lower) %> {
<% for attribute in columns_types -%>
            <%= attribute[:name].camelcase(:lower) %>
<% end -%>
          }
          clientMutationId
          errors
        }
      }
    GRAPHQL

    post '/graphql', params: {query: gql}
    assert_response :success
    json = JSON.parse(response.body)
    assert_not_empty json['data']
    assert_not_empty json['data']['<%= change_one_camelized(:lower) %>']
    assert_equal json['data']['<%= change_one_camelized(:lower) %>']['errors'], []
    assert_equal <%= singular_name_camelized %>.find(id).<%= columns_type_without_primary_key.first[:name] %>, json['data']['<%= change_one_camelized(:lower) %>']['<%= singular_name_camelized(:lower) %>']['<%= columns_type_without_primary_key.first[:name].camelcase(:lower) %>']
  end

  test "can destroy a record" do
    <%= primary_key %> = <%= singular_name_camelized %>.last.<%= primary_key %>
    gql = <<-GRAPHQL
      mutation a {
        <%= destroy_one_camelized(:lower) %>(input: {<%= primary_key.camelcase(:lower) %>: "#{<%= primary_key %>}", clientMutationId: "test-3"} ) 
        {
          <%= singular_name_camelized(:lower) %> {
<% for attribute in columns_types -%>
            <%= attribute[:name].camelcase(:lower) %>
<% end -%>
          }
          clientMutationId
          errors
        }
      }
    GRAPHQL

    post '/graphql', params: {query: gql}
    assert_response :success
    json = JSON.parse(response.body)
    assert_not_empty json['data']
    assert_not_empty json['data']['<%= destroy_one_camelized(:lower) %>']
    assert_equal json['data']['<%= destroy_one_camelized(:lower) %>']['errors'], []

    assert_empty <%= singular_name_camelized %>.where(<%= primary_key %>: <%= primary_key %>)
  end

end
