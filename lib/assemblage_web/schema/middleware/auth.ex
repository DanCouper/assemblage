defmodule AssemblageWeb.Schema.Middleware.Auth do
  @behaviour Absinthe.Middleware

  alias Assemblage.Accounts.User

  def call(resolution, _config) do
    case resolution.context do
      %{current_user: %User{}} ->
        resolution
      _ ->
        resolution |> Absinthe.Resolution.put_result({:ok, "Generic not authorised message"})
    end
  end
end
