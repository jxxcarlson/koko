defmodule Koko.Repo.Migrations.RemoveActiveFromUsers do
  use Ecto.Migration

  def change do
    alter table(:authentication_users) do
      add :active, :boolean, default: true
    end
  end
end
