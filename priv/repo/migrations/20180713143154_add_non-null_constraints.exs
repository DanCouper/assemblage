defmodule :"Elixir.Assemblage.Repo.Migrations.AddNon-nullConstraints" do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      modify :description, :text
      modify :title, :text, null: false
    end

    alter table(:images) do
      modify :description, :text
      modify :title, :text, null: false
      modify :full_url, :text, null: false
    end
  end
end
