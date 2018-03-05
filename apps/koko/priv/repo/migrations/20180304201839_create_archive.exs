defmodule Koko.Repo.Migrations.CreateArchive do
  use Ecto.Migration

  def change do
    create table(:archives) do
      add :name, :text
      add :url, :text
      add :remarks, :text

      timestamps()
    end

  end
end
