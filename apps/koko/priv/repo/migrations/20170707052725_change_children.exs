defmodule Koko.Repo.Migrations.ChangeChildren do
  use Ecto.Migration

    def change do
      alter table(:documents) do

        remove :children
        add :children, {:array, :map}

      end
    end

  end
