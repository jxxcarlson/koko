defmodule Koko.Repo.Migrations.AddDocCountToUser do
  use Ecto.Migration

  def change do
    alter table(:authentication_users) do
      add :document_count, :integer, default: 0
      add :media_count, :integer, default: 0
    end
  end
end
