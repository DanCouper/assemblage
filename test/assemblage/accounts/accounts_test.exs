defmodule Assemblage.AccountsTest do
  use Assemblage.DataCase

  alias Assemblage.Repo
  alias Assemblage.Accounts
  alias Assemblage.Accounts.User

  @valid_attrs %{
    name: "sexysaruman69",
    credential: %{
      email: "saruman@isengard.com",
      password: "palantir"
      }
    }

  def list_users() do
    User
    |> Repo.all()
  end

  describe "registering a user" do
    @long_string (0..101 |> Enum.to_list |> List.to_string)

    def do_register(attrs \\ %{}) do
      attrs
      |> Enum.into(@valid_attrs)
      |> Accounts.register_user()
    end

    test "with valid data, a user is registered" do
      assert {:ok, %User{id: id, credential: credential} = user} = do_register()
      assert user.name == "sexysaruman69"
      assert credential.email == "saruman@isengard.com"
      assert [%User{id: ^id}] = list_users()
    end

    test "with no name, a user is not registered" do
      assert {:error, changeset} = do_register(%{name: nil})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
      assert [] = list_users()
    end

    test "if there is no email supplied, a user is not registered" do
      assert {:error, changeset} = do_register(%{credential: %{email: nil, password: "palantir"}})
      assert %{email: ["can't be blank"]} = errors_on(changeset)[:credential]
      assert [] = list_users()
    end

    test "if password is under 6 characters, a user is not registered" do
      assert {:error, changeset} = do_register(%{credential: %{password: "a", email: "saruman@isengard.com"}})
      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)[:credential]
      assert [] = list_users()
    end

    test "if password is over 100 characters, a user is not registered" do
      assert {:error, changeset} = do_register(%{credential: %{password: @long_string, email: "saruman@isengard.com"}})
      assert %{password: ["should be at most 100 character(s)"]} = errors_on(changeset)[:credential]
      assert [] = list_users()
    end
  end

  describe "updating a user" do
    test "just updating the name" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert {:ok, %User{name: "serioussaruman"}} = Accounts.update_user_info(user, %{name: "serioussaruman"})
    end

    test "cannot update credentials when updating user info" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert {:error, _} = Accounts.update_user_info(user, %{name: "serioussaruman", credential: %{email: "thisaintgoingtowork@test.com", password: "nopenotachance"}})
    end

    test "no name == no update" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.update_user_info(user, %{name: nil})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "given a new email and the current password, can update the email" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert {:ok, %User{credential: %{email: "sexysaruman@isengard.xxx"}}} = Accounts.update_user_email(user, "sexysaruman@isengard.xxx", "palantir")
    end

    test "given a new email and an incorrect current password, cannot update the email" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert {:error, _} = Accounts.update_user_email(user, "sexysaruman@isengard.xxx", "incorrectpassword")
    end

    test "given a the current password and a new password, can update the password" do
      {:ok, %User{credential: %{password_hash: old_hash}} = user} = Accounts.register_user(@valid_attrs)
      assert {:ok, %User{credential: %{password_hash: new_hash}}} = Accounts.update_user_password(user, "pa55w0rd", "palantir")
      assert old_hash != new_hash
    end

    test "given an incorrect current password and a new password, cannot update the password" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert {:error, _} = Accounts.update_user_password(user, "pa55w0rd", "incorrectpassword")
    end
  end

  describe "deleting a user" do
    test "deleting a user removes them from the db" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert [_] = list_users()
      assert {:ok, _} = Accounts.delete_user(user)
      assert [] = list_users()
    end
  end

  describe "signing in" do
    test "given correct details, a user can sign in" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert {:ok, _auth_token} = Accounts.sign_in("saruman@isengard.com", "palantir")
      [user] = list_users()
      assert Accounts.signed_in?(user) == true
    end
  end
end
