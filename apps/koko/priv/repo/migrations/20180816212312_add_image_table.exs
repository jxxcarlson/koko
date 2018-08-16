defmodule Koko.Repo.Migrations.AddImageTable do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :name, :string
      add :user_id, :integer
      add :tags, {:array, :string}, default: []
      add :url, :string
      add :public, :boolean, default: false, null: false
      add :source, :text

      timestamps()
    end

  end
end
