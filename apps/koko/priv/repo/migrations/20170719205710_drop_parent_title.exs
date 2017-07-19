defmodule Koko.Repo.Migrations.DropParentTitle do
  use Ecto.Migration

  def change do

    alter table(:documents) do
      remove :parent_title
    end

  end
end
