defmodule Koko.Repo.Migrations.ChangeParentIdType do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      remove :parent_id
      add :parent_id, :int
    end

  end
end
