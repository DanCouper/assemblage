defmodule Assemblage.Multimedia.Image do
  use Ecto.Schema
  import Ecto.Changeset


  schema "images" do
    field :description, :string
    field :full_src, :string
    field :title, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:full_src, :title, :description])
    |> validate_required([:full_src, :title, :description])
  end
end
