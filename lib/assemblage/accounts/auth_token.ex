defmodule Assemblage.Accounts.AuthToken do
  @moduledoc """
  Bearer token functionality for users. Allows easy
  creation/destruction of auth tokens, and storing on
  the backend makes testing easier + simplifies HTML
  route authentication.

  API auth could be implemented fully on the client-side,
  but Assemblage is envisaged as having both an API -> JS app
  frontend for editorial actions, and an HTML frontend for general
  public viewing.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Assemblage.Accounts.User

  schema "auth_tokens" do
    field :revoked, :boolean, default: false
    field :revoked_at, :utc_datetime
    field :token, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [:token, :revoked, :revoked_at])
    |> validate_required([:token, :revoked])
    |> unique_constraint(:token)
  end
end
