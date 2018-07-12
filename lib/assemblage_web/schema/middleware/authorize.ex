defmodule AssemblageWeb.Schema.Authorize do
  @moduledoc """
  To avoid having to write inline authorisation logic for every query
  or mutation, the logic is here.

  It is very simple - it checks if there is a user in the context under
  the `curent_)user` field. If so, continue. If not error - an
  unauthorised operation has been attempted.
  """

  @behaviour Absinthe.Middleware

  def call(resolution, _) do
    with %{current_user: _current_user} <- resolution.context do
      resolution
    else
      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "unauthorised"})
    end
  end
end
