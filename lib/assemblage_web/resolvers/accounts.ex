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

  def sign_out(_, _, %{context: context}) do
    case context do
      %{current_user: user} ->
        {:ok, Accounts.sign_out(user)}
      _ ->
        {:error, "No user currently signed in, cannot sign out."}
      end
  end
end
