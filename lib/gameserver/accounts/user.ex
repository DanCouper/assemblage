defmodule Gameserver.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string

    timestamps()
  end
end
