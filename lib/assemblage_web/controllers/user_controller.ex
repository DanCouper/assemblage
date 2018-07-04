defmodule AssemblageWeb.UserController do
  use AssemblageWeb, :controller
  # The authenticate_user function plug in action, imported from
  # the auth module plug (in `assemblage_web.ex`)
  plug :authenticate_user when action in [:index, :show]

  alias Assemblage.Accounts
  alias Assemblage.Accounts.User

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
        |> AssemblageWeb.Auth.login(user)
        |> put_flash(:info, "#{user.username} created!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
    end
  end
end
