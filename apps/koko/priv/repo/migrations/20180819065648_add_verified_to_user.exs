defmodule Koko.Repo.Migrations.AddVerifiedToUser do
  use Ecto.Migration

  def change do
    alter table(:authentication_users) do 
      add :verified, :boolean, default: false
    end
  end
end
