defmodule AssemblageWeb.Auth do
  @moduledoc """
  Authentication will work in two stages:

  1. the user ID should be stored in the session
  every time a new user registers or user logs in.
  2. Check if there's a new user in the session and
  store the ID in `conn.assigns` for incoming requests
  so that it can be accessed in controllers and views.
  """
  import Plug.Conn
  import Phoenix.Controller
  alias AssemblageWeb.Router.Helpers, as: Routes

  alias Assemblage.Accounts

  @user_salt "user_salt"
  @max_token_lifespan 365 * 24 * 3600

  @doc false
  def init(opts), do: opts

  @doc """
  A function plug, defined here to allow it to be
  shared between all routers and controllers, rather than
  just keeping it in the `UserController`.
  """
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to view that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

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
  Attempts to authenticate then log in, deferring to the relevant context module
  for the auth logic.
  """
  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user} -> {:ok, login(conn, user)}
      {:error, :unauthorised} -> {:error, :unauthorised, conn}
      {:error, :not_found} -> {:error, :not_found, conn}
    end
  end

  @doc """
  Simply drops the whole session. NOTE if the session needed to be
  held onto, then just deleting `delete_session(conn, :user_id)` would
  be a better bet.
  """
  def logout(conn) do
    configure_session(conn, drop: true)
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

  @doc """
  ALTERNATIVELY, just sign, baby
  """
  def sign(data) do
    Phoenix.Token.sign(AssemblageWeb.Endpoint, @user_salt, data)
  end

  def verify(token) do
    Phoenix.Token.verify(AssemblageWeb.Endpoint, @user_salt, token, max_age: @max_token_lifespan)
  end
end
