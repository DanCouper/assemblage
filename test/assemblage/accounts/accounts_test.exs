defmodule Assemblage.AccountsTest do
  use Assemblage.DataCase

  alias Assemblage.Accounts

  describe "users" do
    alias Assemblage.Accounts.User

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end
  end

  describe "credentials" do
    alias Assemblage.Accounts.Credential

    @valid_attrs %{email: "some email", password_hash: "some password_hash"}
    @update_attrs %{email: "some updated email", password_hash: "some updated password_hash"}
    @invalid_attrs %{email: nil, password_hash: nil}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_credential()

      credential
    end
  end

  describe "auth_tokens" do
    alias Assemblage.Accounts.AuthToken

    @valid_attrs %{revoked: true, revoked_at: "2010-04-17 14:00:00.000000Z", token: "some token"}
    @update_attrs %{revoked: false, revoked_at: "2011-05-18 15:01:01.000000Z", token: "some updated token"}
    @invalid_attrs %{revoked: nil, revoked_at: nil, token: nil}

    def auth_token_fixture(attrs \\ %{}) do
      {:ok, auth_token} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_auth_token()

      auth_token
    end
  end
end
