defmodule Assemblage.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:collections, [:name])
  end
end
