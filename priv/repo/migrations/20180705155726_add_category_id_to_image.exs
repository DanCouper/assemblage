defmodule Assemblage.Repo.Migrations.AddCategoryIdToImage do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :collection_id, references(:collections)
    end
  end
end
