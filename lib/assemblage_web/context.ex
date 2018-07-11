defmodule AssemblageWeb.Context do
  @moduledoc """
  GraphQL fields that need to be secured have to have access to the
  relevant data that specifies whether or not they should be accessible.

  The Absinthe functionality that addresses this is called the
  execution context, where values can be set that are available to
  all resolvers.  In the case of AssemblageWeb, data relating to a
  user - in particular a token if they have been authorised - should live
  within the execution context.

  The final argument to `resolve` callback functions is an
  `Absinthe.Resolution` struct that includes `context`. By using a plug
  that runs prior to Absinthe's own `Absinthe.Plug`, the context can be
  set up.
  """
  @behaviour Plug
  import Plug.Conn

  alias Assemblage.Accounts

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    IO.inspect [context: context]
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- Accounts.verify(token) do
      %{current_user: user}
    else
      _ -> %{}
    end
  end
end
