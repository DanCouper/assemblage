defmodule Assemblage.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :title, :string
      add :description, :string
      add :full_url, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:images, [:user_id])
  end
end
