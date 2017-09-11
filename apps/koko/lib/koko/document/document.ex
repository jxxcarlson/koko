defmodule Koko.Document.Document do

  use Ecto.Schema
  import Ecto.Changeset

  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.User.User


  schema "documents" do
    field :content, :string
    field :rendered_content, :string
    field :title, :string
    field :author_id, :integer
    field :author_name, :string
    field :attributes, :map
    field :tags, {:array, :string}
    field :identifier, :string
    embeds_many :children, Child, on_replace: :delete
    field :parent_id, :integer
    field :viewed_at, :utc_datetime

    timestamps()
  end

 #, on_replace: :delete

  @doc false
  def changeset(%Document{} = document, attrs) do
    document
    |> cast(attrs, [:title, :author_id, :content, :rendered_content,
      :attributes, :tags, :identifier, :parent_id, :viewed_at,
      :author_name])
    |> cast_embed(:children)
    |> validate_required([:title, :author_id, :content])
  end

  def default_attributes() do
    %{ "public" => false,
       "text_type" => "adoc",
       "doc_type" => "standard",
       "level" => 0
     }
  end

  def default_attributes(document) do
    Map.merge default_attributes(), document.attributes
  end

  def tags_as_string(document) do
    document.tags |> Enum.join(", ")
  end

  @doc"""
    iex> Koko.Document.Document.normalize_string("Foo bar#$!1234")
    "Foo_bar1234"
  """
  def normalize_string(str) do
    Regex.replace(~r/[^A-Za-z0-9_.: ]/, str, "") |> String.replace(" ", "_")
  end

  """
  Example:
  > d = %Document{id: 1, title: "Foo & Bar", author_id: 1, inserted_at: ~N[2017-08-22 01:21:07.712814]}
  > Document.make_identifier(d)
  "jxxcarlson.foo__bar.2017-8-22@1-21-7.2183ee"

  Note that a database lookup is require for this example
  """
  def make_identifier(document) do
    user = Repo.get(User, document.author_id)
    part0 = user.username
    part1 = document.title |> String.downcase |> normalize_string
    date = document.inserted_at
    part2 = "#{date.year}-#{date.month}-#{date.day}@#{date.hour}-#{date.minute}-#{date.second}"
    part3 = SecureRandom.hex(3)
    Enum.join([part0,  part1, part2, part3], ".")
  end

  def rewrite_identifier(document) do
    new_identifier = document.identifier
      |> String.split(":")
      |> Enum.join("-")
    cs = changeset(document, %{identifier: new_identifier})
    Repo.update(cs)
  end

  def set_identifier(document) do
   identifier = make_identifier(document)
   cs = changeset(document, %{identifier: identifier})
   Repo.update(cs)
  end

  def set_level(document, level) do
   attributes = Map.merge(document.attributes, %{level: level})
   cs = changeset(document, %{attributes: attributes})
   Repo.update(cs)
  end

  def set_level_of_child(child) do
    doc = Repo.get(Document, child.doc_id)
    if doc != nil do
      set_level(doc, child.level)
    end
  end

  def set_defaults(document, level) do
   cs = changeset(document, %{attributes: %{level: level, public: false, doc_type: "standard", text_type: "adoc"}})
   Repo.update(cs)
  end

  # Set the parent_id of document to id
  def set_parent(document, id) do
    cs = changeset(document, %{parent_id: id})
    Repo.update(cs)
  end

  # document -> changeset
  def update_identifier(changeset, document) do
    part = String.split(document.identifier, ".")
    part1 = document.title |> String.downcase |> normalize_string
    identifier = Enum.join [(Enum.at part, 0), part1, (Enum.at part, 2), (Enum.at part, 3)], "."
    Ecto.Changeset.put_change(changeset, :identifier, identifier)
  end

  def update_viewed_at(changeset) do
    Ecto.Changeset.put_change(changeset, :viewed_at, DateTime.utc_now())
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

  def parent(document) do
    if document.parent_id == nil do
      nil
    else
      Repo.get(Document, document.parent_id)
    end
  end

  # Needs test
  def parent_title(document) do
      p = parent(document)
      if p == nil do
        ""
      else
        p.title
      end
  end

  # return document corresponding to a child
  def child_document(child) do
    Repo.get(Document, child.doc_id )
  end

  def add_authorname(document) do
   author = Koko.User.Query.get(document.author_id)
   cs = changeset(document, %{author_name: author.username})
   Repo.update(cs)
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
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :level, :integer
    field :title, :string
    field :doc_id, :integer
    field :doc_identifier, :string
    field :comment, :string
  end

  def changeset(%Child{} = child, attrs) do
    child
    |> cast(attrs, [:level, :title, :doc_id, :doc_identifier, :comment])
  end


end