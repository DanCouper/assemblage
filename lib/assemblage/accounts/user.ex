defmodule Assemblage.Accounts.User do
  use Ecto.Schema
  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Assemblage.Accounts.{ User, AuthToken, Credential }

  schema "users" do
    field :name, :string
    # NOTE just keep as `has_one` until want to
    # test/implement other methods.
    has_one :credential, Credential, on_replace: :update
    has_one :auth_token, AuthToken
    timestamps()
  end

  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> cast_assoc(:credential, with: &Credential.changeset/2, required: true)
  end

  def credential_changeset(user, params) do
    user
    |> changeset(params)
    |> cast_assoc(:credential, with: &Credential.update_changeset/2, required: true)
  end

  def token_changeset(user, params) do
    user
    |> changeset(params)
    |> cast_assoc(:auth_token, with: &AuthToken.changeset/2, required: true)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
    |> unique_constraint(:name)
  end

  def by_email(email) do
    from(u in User, join: c in assoc(u, :credential), where: c.email == ^email)
  end
end
