defmodule GameserverWeb.Auth do
  @moduledoc """
  Authentication will work in two stages:

  1. the user ID should be stored in the session
  every time a new user registers or user logs in.
  2. Check if there's a new user in the session and
  store the ID in `conn.assigns` for incoming requests
  so that it can be accessed in controllers and views.

  This plug covers the second part.
  """
  import Plug.Conn

  alias Gameserver.Accounts

  @doc false
  def init(opts), do: opts

  @doc """
  First requirement:

  Given the session + a user, stores the `:user_id` in the session.
  """
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    # NOTE this last step is IMPORTANT, prevents session fixation attacks:
    # it sends the session cookie back with a different identifier.
    |> configure_session(renew: true)
  end

  @doc """
  Second requirement:

  Checks if a `:user_id` is stored in the session, and if so,
  look it up and assign the result in the connection under
  the `current_user` key.
  """
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end
end
