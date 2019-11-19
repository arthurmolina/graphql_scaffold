require 'test_helper'

class Graphql1stTest < ActionDispatch::IntegrationTest
    test "can see the graphql endpoint" do
      post '/graphql', params: {}
      assert_response :success
      assert_equal response.body, '{"errors":[{"message":"No query string was present"}]}'
    end
end
