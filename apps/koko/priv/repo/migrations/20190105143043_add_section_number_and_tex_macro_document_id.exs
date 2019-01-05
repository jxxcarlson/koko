defmodule Koko.Repo.Migrations.AddSectionNumberAndTexMacroDocumentId do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :section_number, :int
      add :tex_macro_document_id, :int
    end
  end
end
