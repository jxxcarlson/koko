defmodule Koko.Repo.Migrations.AddToDocs do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :author_id, references(:authentication_users, on_delete: :nothing)
      add :identifier, :string
      add :parent_id, :string
      add :children, {:array, :string}
      add :tags, {:array, :string}
      add :attributes, :map
      add :resources, {:array, :map}
      add :viewed_at, :utc_datetime
      add :edited_at, :utc_datetime
    end
  end
end
