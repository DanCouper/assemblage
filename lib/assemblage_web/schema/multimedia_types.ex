defmodule AssemblageWeb.Schema.MultimediaTypes do
  use Absinthe.Schema.Notation

  object :image do
    field :id, :id
    @desc "The URL source for the full-size image"
    field :full_src, :string
    @desc "The title of the image"
    field :title, :string
    @desc  "A detailed description of the image"
    field :description, :string
    @desc "The collection this image belongs to"
    field :collection, :collection
  end

  object :collection do
    @desc "The [unique] name of the collection"
    field :name, :string
  end
end
