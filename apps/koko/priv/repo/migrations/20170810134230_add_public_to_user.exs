defmodule Koko.Repo.Migrations.AddPublicToUser do
  use Ecto.Migration

  def change do
    alter table(:authentication_users) do
      add :public, :boolean, default: true
    end

  end
end
