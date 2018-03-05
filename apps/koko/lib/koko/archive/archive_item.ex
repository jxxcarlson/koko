defmodule Koko.Archive.Item do

  # https://hexdocs.pm/ecto/getting-started.html

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Archive.Item
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

  def get_version(document) do
     version_tag_list = Utility.get_with_prefix(document.tags, "version:")
     if length(version_tag_list) == 0 do
       0
     else
       [_, version_string] = version_tag_list |> hd |> (String.split ":")
       String.to_integer version_string
     end
  end

  def update_tags(document, version) do
    Utility.remove_item(document.tags, "version:") ++ [ "version:" <> Integer.to_string(version) ]
  end

  def set_version(document, version) do
    new_tags = update_tags(document, version)
    cs = Document.changeset(document, %{tags: new_tags})
    Repo.update(cs)
  end

  def increment_version!(document) do
    new_version = get_version(document) + 1
    new_tags = update_tags(document, new_version)
    cs = Document.changeset(document, %{tags: new_tags})
    Repo.update(cs)
    new_version
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

  def archive_data(bucket, archive, document, version) do
    prefix = bucket <> ".s3.amazonaws.com"
    path = archive_path(archive, document, version)
    url = ["http:/", prefix, path] |> Enum.join("/")
    [url, path]
  end

  def archive_document!(bucket, path, document) do
    ExAws.S3.put_object(bucket, path, document.content) |> ExAws.request
  end


  # http://noteshare-test.s3.amazonaws.com/yada.txt

    def new_archive(bucket, archive, document, remarks) do
    if archive.author_id == document.author_id do
      do_new_archive(bucket, archive, document, remarks)
    end
  end

  def do_new_archive(bucket, archive, document, remarks) do
    version = increment_version!(document)
    [url, path] = archive_data(bucket, archive, document, version)

    archive_document!(bucket, path, document)

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
    url = "http://localhost:4000/archive/document/#{Integer.to_string(id)}"
    "<li><a href=\"#{url}\">Version #{Integer.to_string(version)}: #{Integer.to_string(length)} characters</a></li>\n"
  end

  def link_for_item2(item) do
    [version, length, url] = item
    "<li><a href=\"#{url}\" Content-Type: text/plain >Version #{Integer.to_string(version)}: #{Integer.to_string(length)} characters</a></li>\n"
  end

  def links_for_document(document) do
    items_for_document(document) |> (Enum.reduce "", fn(item, acc) -> (acc <> link_for_item(item)) end)
  end

  def get_archived_item(bucket, archive, item) do
    document = Repo.get(Document, item.doc_id)
    path = archive_path(archive, document, item.version)
    reply = ExAws.S3.get_object(bucket, path) |> ExAws.request
    case reply do
      {:ok, data } -> data.body
      _ -> "Error retrieving archived file"
    end
  end

end
