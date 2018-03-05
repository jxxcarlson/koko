defmodule Koko.Archive.Item do

  # https://hexdocs.pm/ecto/getting-started.html

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Archive.Item
  alias Koko.Archive.Archive
  alias Koko.Utility


  schema "archive_items" do
    field :archive_id, :integer
    field :doc_id, :integer
    field :author_id, :integer
    field :version, :integer
    field :url, :string
    field :length, :integer
    field :remarks, :string

    timestamps()
  end

  def changeset(%Item{} = item, attrs) do
    item
    |> cast(attrs, [:archive_id, :doc_id, :author_id, :version, :url, :length, :remarks])
    |> validate_required([:doc_id, :archive_id, :author_id,   :url])
  end


  def update_tags(document, version) do
    Utility.remove_item(document.tags, "version:") ++ [ "version:" <> Integer.to_string(version) ]
  end


  def file_extension(document) do
    case document.attributes["text_type"] do
        "latex" -> "tex"
        "adoc" -> "adoc"
        _ -> "txt"
    end
  end

  def archive_path(archive, document, version) do
    normalized_title = document.title |> String.downcase |> Utility.normalize_string
    normalized_title = normalized_title <> "-version" <> Integer.to_string(version) <> "." <> file_extension(document)
    [document.author_name, archive.name, normalized_title ] |> Enum.join("/")
  end

  def archive_data(archive, document, version) do
    prefix = archive.bucket <> ".s3.amazonaws.com"
    path = archive_path(archive, document, version)
    url = ["http:/", prefix, path] |> Enum.join("/")
    [url, path]
  end

  def put_document!(bucket, path, document) do
    ExAws.S3.put_object(bucket, path, document.content) |> ExAws.request
  end


  # http://noteshare-test.s3.amazonaws.com/yada.txt

  def archive_document(document, remarks) do
    archive_name = Document.get_archive_name(document)
    archive = Archive.get_by_name_and_author(archive_name, document.author_id)
    if archive.author_id == document.author_id do
      do_archive_document(archive, document, remarks)
    end
    archive.bucket
  end

  def do_archive_document(archive, document, remarks) do
    {:ok, updated_doc} = Document.increment_version(document)
    version = Document.get_version(updated_doc) + 1
    [url, path] = archive_data(archive, document, version)
    put_document!(archive.bucket, path, document)

    attrs = %{doc_id: document.id,
              archive_id: archive.id,
              author_id: document.author_id,
              version: version,
              url: url,
              length: String.length(document.content),
              remarks: remarks}

    %Item{}
      |> Item.changeset(attrs)
      |> Repo.insert()
  end

  def items_for_document(document) do
    query = from item in "archive_items",
          where: item.doc_id == ^document.id,
          select: [item.version, item.length,   item.id]
    Repo.all(query)
  end

  def link_for_item(item) do
    [version, length, id] = item
    url = "#{Koko.Configuration.host()}/archive/document/#{Integer.to_string(id)}"
    "<li><a href=\"#{url}\">Version #{Integer.to_string(version)}: #{Integer.to_string(length)} characters</a></li>\n"
  end

  def links_for_document(document) do
    items_for_document(document) |> (Enum.reduce "", fn(item, acc) -> (acc <> link_for_item(item)) end)
  end

  def get_archived_item(archive, item) do
    document = Repo.get(Document, item.doc_id)
    path = archive_path(archive, document, item.version)
    reply = ExAws.S3.get_object(archive.bucket, path) |> ExAws.request
    case reply do
      {:ok, data } -> data.body
      _ -> "Error retrieving archived file"
    end
  end

end
