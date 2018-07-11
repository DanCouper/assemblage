defmodule AssemblageWeb.Resolvers.Accounts do
  alias Assemblage.Accounts

  def list_users(_, _, _) do
    {:ok, Accounts.list_users()}
  end

  def register(_, %{name: _name, email: _email, password: _password} = registration_attrs, _) do
    with {:ok, user} <- Accounts.register(registration_attrs) do
      {:ok, %{user: user}}
    end
  end

  def sign_in(_, %{email: email, password: password}, _) do
    with {:ok, user} <- Accounts.sign_in(email, password) do
      {:ok, %{user: user}}
    end
  end

  def sign_out(_, %{user: user}, _) do
    Accounts.sign_out(user)
  end
end
