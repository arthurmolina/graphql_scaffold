require 'test_helper'

class Graphql<%= plural_name_camelized %>Test < ActionDispatch::IntegrationTest
  setup do
    @<%= singular_name_snaked %> = <%= plural_name_snaked %>(:one)
  end

  test "can see a result" do
    gql = <<-GRAPHQL
      {
        <%= list_many %>(first: 10, sort_by: {field: <%= columns_type_without_primary_key.sample[:name] %>, sortDirection: asc}) {
<% for attribute in columns_types -%>
            <%= attribute[:name] %>
<% end -%>
        }
      }
    GRAPHQL

    post '/graphql', params: {query: gql}
    assert_response :success
    json = JSON.parse(response.body)
    assert_not_empty json['data']
    assert_not_empty json['data']['<%= list_many %>']
  end

  test "can add a record" do
    gql = <<-GRAPHQL
      mutation a {
        <%= create_one %>(input: {
<% for attribute in columns_type_without_primary_key -%>
          <%= attribute[:name] %>: "<%= attribute[:sample] %>",
<% end -%>
          clientMutationId: "test-1"
        } ) 
        {
          <%= singular_name_snaked %> {
<% for attribute in columns_types -%>
            <%= attribute[:name] %>
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
    #puts response.body
    
    assert_not_empty json['data']
    assert_not_empty json['data']['<%= create_one %>']
    assert_not_empty json['data']['<%= create_one %>']['<%= singular_name_snaked %>']
    assert_empty json['data']['<%= create_one %>']['errors']

    <%= primary_key %> = json['data']['<%= create_one %>']['<%= singular_name_snaked %>']['<%= primary_key %>']
    assert_not_empty <%= singular_name_camelized %>.where(<%= primary_key %>: <%= primary_key %>)
  end

  test "can change a record" do
    <%= primary_key %> = <%= singular_name_camelized %>.last.<%= primary_key %>
    gql = <<-GRAPHQL
      mutation a {
        <%= change_one %>(input: {
          <%= primary_key %>: "#{<%= primary_key %>}", 
<% for attribute in columns_type_without_primary_key -%>
          <%= attribute[:name] %>: "<%= attribute[:sample] %>",
<% end -%>
          clientMutationId: "test-2"} ) 
        {
          <%= singular_name_snaked %> {
<% for attribute in columns_types -%>
            <%= attribute[:name] %>
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
    assert_not_empty json['data']['<%= change_one %>']
    assert_empty json['data']['<%= change_one %>']['errors']

    assert_equal <%= singular_name_camelized %>.find(id).url, json['data']['<%= change_one %>']['<%= singular_name_snaked %>']['url']
  end

  test "can destroy a record" do
    <%= primary_key %> = <%= singular_name_camelized %>.last.<%= primary_key %>
    gql = <<-GRAPHQL
      mutation a {
        <%= destroy_one %>(input: {<%= primary_key %>: "#{<%= primary_key %>}", clientMutationId: "test-3"} ) 
        {
          <%= singular_name_snaked %> {
<% for attribute in columns_types -%>
            <%= attribute[:name] %>
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
    assert_not_empty json['data']['<%= destroy_one %>']
    assert_empty json['data']['<%= destroy_one %>']['errors']

    assert_empty <%= singular_name_camelized %>.where(<%= primary_key %>: <%= primary_key %>)
  end

end
