defmodule Koko.Repo.Migrations.DefaultBlurb do
  use Ecto.Migration

  def change do
    alter table(:authentication_users) do
      remove :blurb
      add :blurb, :string, default: ""
    end
  end

end
