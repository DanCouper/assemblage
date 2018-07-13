defmodule Assemblage.Accounts.Credential do
  @moduledoc """
  Stores a users credentials, for example an email and a password hash.

  This is kept seperate from the user struct itself; the values in it
  should not be exposed unless explicitly requested. Note that this
  structuring does complicate reads/write code somewhat, but that
  complication seems a fair exchange for the added security.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Assemblage.Accounts.User

  schema "credentials" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 6, max: 100)
    |> unique_constraint(:email, downcase: true)
    |> put_password_hash()
  end

  # Discrete operation to update email: to do so a user
  # will need to go through security measures, makes sense to
  # keep  the changeset functionality atomic.
  @doc false
  def update_changeset(credential, %{email: email} = params) do
    credential
    |> cast(params, [:email])
    |> unique_constraint(:email, downcase: true)
    |> put_change(:email, email)
  end

  # Discrete operation to update password: to do so a user
  # will need to go through security measures, makes sense to
  # keep  the changeset functionality atomic.
  @doc false
  def update_changeset(credential, %{password: _} = params) do
    credential
    |> cast(params, [:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_password_hash()
  end

  # If valid, hash the value of the virtual password field and put that
  # in the changeset.
  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: p}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(p))

      _ ->
        changeset
    end
  end
end
