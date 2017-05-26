defmodule Koko.Repo.Migrations.CreateKoko.DocManager.Document do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string
      add :content, :text
      add :rendered_content, :text

      timestamps()
    end

  end
end
