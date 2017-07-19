defmodule Koko.Repo.Migrations.AddParentTitle do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :parent_title, :string
    end
  end
end
