defmodule GameserverWeb.UserController do
  use GameserverWeb, :controller
  plug :authenticate when action in [:index, :show]

  alias Gameserver.Accounts
  alias Gameserver.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> GameserverWeb.Auth.login(user)
        |> put_flash(:info, "#{user.username} created!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
    end
  end

  # This is a function plug. It's using the Auth module plug.
  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to view that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
