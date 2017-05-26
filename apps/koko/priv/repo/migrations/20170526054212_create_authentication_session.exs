defmodule Koko.Repo.Migrations.CreateKoko.Authentication.Session do
  use Ecto.Migration

  def change do
    create table(:authentication_sessions) do
      add :token, :string
      add :user_id, references(:authentication_users, on_delete: :nothing)

      timestamps()
    end

    create index(:authentication_sessions, [:user_id])
  end
end
