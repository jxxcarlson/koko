defmodule Koko.DocManager.Document do
  use Ecto.Schema
  import Ecto.Changeset
  import SecureRandom
  alias Koko.DocManager.Document
  alias Koko.Repo
  alias Koko.Authentication.User


  schema "documents" do
    field :content, :string
    field :rendered_content, :string
    field :title, :string
    field :author_id, :integer
    field :attributes, :map
    field :tags, {:array, :string}
    field :identifier, :string
    embeds_many :children, Child

    timestamps()
  end

  @doc false
  def changeset(%Document{} = document, attrs) do
    document
    |> cast(attrs, [:title, :author_id, :content, :rendered_content, :attributes, :tags, :identifier])
    # |> cast_embed([:children])
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
    Regex.replace(~r/[^A-Za-z0-9_.: ]/, str, "") |> String.replace(" ", "_")
  end

 # alias Koko.DocManager.Document; alias Koko.Repo; alias Koko.Authentication.User;
   # u = Repo.get(User, 1); d = Repo.get(Document, 1)
  def make_identifier(document) do
    user = Repo.get(User, document.author_id)
    part0 = user.username
    part1 = document.title |> String.downcase |> normalize_string
    date = document.inserted_at
    part2 = "#{date.year}-#{date.month}-#{date.day}@#{date.hour}:#{date.minute}:#{date.second}"
    part3 = SecureRandom.hex(3)
    Enum.join([part0,  part1, part2, part3], ".")
  end

  def set_identifier(document) do
   identifier = make_identifier(document)
   cs = changeset(document, %{identifier: identifier})
   Repo.update(cs)
  end

  def update_identifier(document) do
    part = String.split(document.identifier, ".")
    part1 = document.title |> String.downcase |> normalize_string
    identifier = Enum.join [(Enum.at part, 0), part1, (Enum.at part, 2), (Enum.at part, 3)], "."
    cs = changeset(document, %{identifier: identifier})
    Repo.update(cs)
  end

  def identifier_suffix(document) do
      part = String.split(document.identifier, ".")
      tail = part |> tl |> tl
      Enum.join(tail, ".")
  end

  # https://hexdocs.pm/ecto/Ecto.Changeset.html#put_embed/4
  def update_children(document, children) do
    Ecto.Changeset.change(document)
     |> Ecto.Changeset.put_embed(:children, children)
     |> Repo.update!
  end

end

# alias Koko.Repo; alias Koko.DocManager.Document
# doc = Repo.get(Document, 1)
# https://robots.thoughtbot.com/embedding-elixir-structs-in-ecto-models
# http://blog.simonstrom.xyz/w/
# http://blog.plataformatec.com.br/2015/08/working-with-ecto-associations-and-embeds/
# ch = [%Child{ level: 2, title: "Foo", doc_id: 33, doc_identifier: "jxx.foo.abc"}]
defmodule Child do
  use Ecto.Schema
  embedded_schema do
    field :level, :integer
    field :title, :string
    field :doc_id, :integer
    field :doc_identifier, :string
  end
end
