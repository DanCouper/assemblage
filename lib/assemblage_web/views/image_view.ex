defmodule AssemblageWeb.ImageView do
  use AssemblageWeb, :view

  def collection_select_options(collections) do
    for collection <- collections, do: {collection.name, collection.id}
  end
end
