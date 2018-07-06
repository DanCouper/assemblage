defmodule AssemblageWeb.Resolvers.Accounts do
  alias Assemblage.Accounts

  def me(_, _, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def me(_, _, _) do
    {:ok, nil}
  end

  def login(_, %{email: email, password: password}, _) do
    case Accounts.authenticate_by_email_and_pass(email, password) do
      {:ok, user} ->
        token = AssemblageWeb.Auth.sign(%{id: user.id})

        {:ok, %{token: token, user: user}}

      {:error, _code} ->
        {:error, "Nope"}
    end
  end
end
