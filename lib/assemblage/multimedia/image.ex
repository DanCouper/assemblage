defmodule Assemblage.Multimedia.Image do
  use Ecto.Schema

  import Ecto.Changeset

  alias Assemblage.Accounts.User

  schema "images" do
    field :description, :string
    field :full_url, :string
    field :title, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:title, :description, :full_url])
    |> validate_required([:title, :description, :full_url])
  end
end
