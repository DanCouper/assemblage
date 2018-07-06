defmodule Assemblage.Schema.Mutation.LoginTest do
  use AssemblageWeb.ConnCase, async: true

  @login """
  mutation($email: String!) {
    login(email: $email, password: "isengard") {
      token
      user { username }
    }
  }
  """
  @skip true
  test "revoking a user session" do
    {:ok, user} = Factory.create_user()

    login_req = post(build_conn(), "/api/test", %{ query: @login, variables: %{"email" => user.credential.email}})

    assert %{"data" => %{ "login" => %{
      "token" => token,
      "user" => user_data
    }}} = json_response(response, 200)

    assert %{"username" => user.username } == user_data

    assert {:ok, %{id: user.id}} == AssemblageWeb.Auth.verify(token)
  end
end
