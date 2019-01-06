defmodule Koko.Repo.Migrations.AddCoverArtUrl do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :cover_art_url, :string
    end
  end
end
