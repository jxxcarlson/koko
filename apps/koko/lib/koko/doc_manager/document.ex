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

  def default_attributes() do
    %{ "public" => false,
       "text_type" => "adoc",
       "doc_type" => "standard"
     }
  end

  def default_attributes(document) do
    Map.merge default_attributes(), document.attributes
  end

end
