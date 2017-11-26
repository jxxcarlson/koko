defmodule :"Elixir.Koko.Repo.Migrations.AddIdlistTo-user" do
  use Ecto.Migration

  def change do
    alter table(:authentication_users) do
      add :document_ids, {:array, :integer}, default: []
      add :current_document_id, :integer, default: 0
    end
  end

end
