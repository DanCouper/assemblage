defmodule AssemblageWeb.Context do
  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    IO.inspect(context: context)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- Plug.Conn.get_req_header(conn, "authorization"),
         {:ok, %{id: id}} <- AssemblageWeb.Auth.verify(token),
         %{} = user <- Assemblage.Accounts.get_user_by_id(id) do
      %{current_user: user}
    else
      _ -> %{}
    end
  end
end
