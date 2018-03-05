defmodule Koko.Repo.Migrations.AddBucketToArchive do
  use Ecto.Migration

  def change do
    alter table(:archives) do
      add :bucket, :text
    end
  end
  
end
