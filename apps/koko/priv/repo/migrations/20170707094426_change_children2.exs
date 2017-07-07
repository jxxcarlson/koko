defmodule Koko.Repo.Migrations.ChangeChildren2 do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      remove :children
      add :children, {:array, :map}, default: []
    end
  end
end
