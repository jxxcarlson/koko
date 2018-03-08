defmodule :"Elixir.Koko.Repo.Migrations.Add acccess field to documents" do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :access, :map
    end
  end
end
