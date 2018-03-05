defmodule Koko.Web.ArchiveController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Archive.Item
  alias Koko.Archive.Archive

  plug :put_layout, false

  def index(conn, %{"id" => id}) do

    document = Repo.get(Document, String.to_integer(id))
    links = Koko.Archive.Item.links_for_document(document)

    conn |> render("index.html", links: links, title: document.title)

  end

  def show(conn, %{"id" => id}) do
    item = Repo.get(Item, String.to_integer(id))
    document = Repo.get(Document, item.doc_id)
    version_string = item.version |> Integer.to_string
    archive = Repo.get(Archive, item.archive_id)
    reply = Koko.Archive.Item.get_archived_item("noteshare-test", archive, item)
    conn |> render("show.html", text: reply, version: version_string,
             title: document.title, remarks: item.remarks)

  end
end
