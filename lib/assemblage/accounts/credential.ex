defmodule Assemblage.Accounts.Credential do
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