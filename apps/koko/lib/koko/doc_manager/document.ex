defmodule Koko.DocManager.Document do
  use Ecto.Schema
  import Ecto.Changeset
  alias Koko.DocManager.Document


  schema "documents" do
    field :content, :string
    field :rendered_content, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(%Document{} = document, attrs) do
    document
    |> cast(attrs, [:title, :content, :rendered_content])
    |> validate_required([:title, :content, :rendered_content])
  end
end
