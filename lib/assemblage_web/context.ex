defmodule AssemblageWeb.Context do
  alias Assemblage.Accounts
  alias Plug.Conn

  @user_salt "user_salt"
  @max_token_lifespan 365 * 24 * 3600

  def init(opts), do: opts

  def call(conn, _) do
    context = build_user_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_user_context(conn) do
    with ["Bearer " <> token] <- Conn.get_req_header(conn, "authorization"),
         {:ok, _}     <- verify(token),
         %{} = user           <- Accounts.get_user_by(access_token: token) do
      %{current_user: user}
    else
      _ -> %{}
    end
  end

  def sign(data) do
    Phoenix.Token.sign(AssemblageWeb.Endpoint, @user_salt, data)
  end

  def verify(token) do
    Phoenix.Token.verify(AssemblageWeb.Endpoint, @user_salt, token, max_age: @max_token_lifespan)
  end
end
