defmodule AssemblageWeb.Resolvers.Accounts do
  alias Assemblage.Accounts

  def login(_, %{email: email, password: password}, _) do
    case Accounts.authenticate_by_email_and_pass(email, password) do
      {:ok, user} ->
        token = AssemblageWeb.Context.sign(%{id: user.id})
        Accounts.store_access_token(user, token)
        {:ok, %{token: token, user: user}}

      {:error, _code} ->
        {:error, "Nope"}
    end
  end

  def logout(_, %{context: %{current_user: current_user}}, _) do
    Accounts.revoke_access_token(current_user)
  end
end
