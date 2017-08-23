defmodule Koko.Repo.Migrations.AddAuthornameToDocument do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :author_name, :string
    end
  end
end
