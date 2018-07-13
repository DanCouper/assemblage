defmodule Assemblage.Repo.Migrations.SwitchToTextFieldsWhereRelevant do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      modify :description, :text
      modify :title, :text
    end

    alter table(:images) do
      modify :description, :text
      modify :title, :text
      modify :full_url, :text
    end
  end
end
