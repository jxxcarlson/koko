defmodule Koko.Repo.Migrations.CreateKoko.Authentication.User do
  use Ecto.Migration

  def change do
    create table(:authentication_users) do
      add :name, :string
      add :username, :string
      add :email, :string
      add :password_hash, :string
      add :admin, :boolean, default: false, null: false
      add :blurb, :text

      timestamps()
    end

  end
end
