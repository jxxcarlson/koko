defmodule Koko.DocManager.Document do
  use Ecto.Schema
  import Ecto.Changeset
  alias Koko.DocManager.Document


  schema "documents" do
    field :content, :string
    field :rendered_content, :string
    field :title, :string
    field :author_id, :integer
    field :attributes, :map

    timestamps()
  end

  @doc false
  def changeset(%Document{} = document, attrs) do
    document
    |> cast(attrs, [:title, :author_id, :content, :rendered_content, :attributes])
    |> validate_required([:title, :author_id, :content])
  end
end
