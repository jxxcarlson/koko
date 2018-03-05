defmodule Koko.Repo.Migrations.CreateArchiveItems do
  use Ecto.Migration

  def change do
    create table(:archive_items) do
      add :archive_id, :integer
      add :doc_id, :integer
      add :version, :integer
      add :url, :text
      add :length, :integer
      add :remarks, :text

      timestamps()
    end

  end
end
