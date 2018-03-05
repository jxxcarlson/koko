defmodule Koko.Repo.Migrations.AddAuthorIdToArchiveItem do
  use Ecto.Migration

  def change do
    alter table(:archive_items) do
      add :author_id, :integer
    end
  end
end
