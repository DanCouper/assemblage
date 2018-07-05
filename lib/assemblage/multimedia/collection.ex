defmodule Assemblage.Multimedia.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query


  schema "collections" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc """
  Load in the collections alphabetically.
  NOTE this is just an example: the collections will need to be
  fleshed out - curently can only be added in the console.
  """
  def alphabetical(query) do
    from c in query, order_by: c.name
  end
end
