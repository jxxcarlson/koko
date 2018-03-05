defmodule Koko.Repo.Migrations.AddAuthorIdToArchive do
  use Ecto.Migration

  def change do
    alter table(:archives) do
      add :author_id, :integer
    end
  end
end
