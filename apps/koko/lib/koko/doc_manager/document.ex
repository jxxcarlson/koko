defmodule Koko.DocManager.Document do
  use Ecto.Schema
  import Ecto.Changeset
  import SecureRandom
  alias Koko.DocManager.Document


  schema "documents" do
    field :content, :string
    field :rendered_content, :string
    field :title, :string
    field :author_id, :integer
    field :attributes, :map
    field :tags, {:array, :string}
    field :identifier, :string

    timestamps()
  end

  @doc false
  def changeset(%Document{} = document, attrs) do
    document
    |> cast(attrs, [:title, :author_id, :content, :rendered_content, :attributes, :tags, :identifier])
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

  def tags_as_string(document) do
    document.tags |> Enum.join(", ")
  end

  def normalize_string(str) do
    Regex.replace(~r/[^A-Za-z0-9_.:]/, str, "")
  end

 # alias Koko.DocManager.Document; alias Koko.Repo; alias Koko.Authentication.User;
 # u = Repo.get(User, 1); d = Repo.get(Document, 1)
  def make_identifier(user, document) do
    part1 = user.username
    part2 = document.title |> String.downcase |> normalize_string
    date = document.inserted_at
    part3 = "#{date.year}-#{date.month}-#{date.day}@#{date.hour}:#{date.minute}:#{date.second}"
    part4 = SecureRandom.hex(3)
    Enum.join([part1, part2, part3, part4], ".")
  end


end
