defmodule Assemblage.Multimedia.Image do
  use Ecto.Schema
  import Ecto.Changeset

  alias Assemblage.Accounts.User
  alias Assemblage.Multimedia.Collection

  schema "images" do
    field :description, :string
    field :full_src, :string
    field :title, :string
    belongs_to :user, User
    belongs_to :collection, Collection

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:full_src, :title, :description, :collection_id])
    |> validate_required([:full_src, :title, :description])
    |> assoc_constraint(:collection)
  end
end
