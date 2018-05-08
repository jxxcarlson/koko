defmodule Koko.Repo.Migrations.ChangeConstraint do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE documents DROP CONSTRAINT documents_author_id_fkey"
    alter table(:documents) do
      modify :author_id, references(:authentication_users, on_delete: :delete_all)
    end
  end

end
