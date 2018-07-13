defmodule Assemblage.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def up do
    create table(:articles) do
      add :title, :string
      add :description, :string
      add :sections, :jsonb, default: "[]"
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:articles, [:user_id])
    execute "CREATE INDEX sections_gin ON articles USING GIN (sections);"
  end

  def down do
    drop table(:articles)

    drop index(:articles, [:user_id])
    execute "DROP INDEX sections_gin;"
  end
end
