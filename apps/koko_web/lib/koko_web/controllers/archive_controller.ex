defmodule Koko.Web.ArchiveController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Archive.Item
  alias Koko.Archive.Archive
  alias Koko.User.User

  plug :put_layout, false

  def index(conn, %{"id" => id}) do
    IO.puts "THIS IS ARCHIVE.INDEX"
    document = Repo.get(Document, String.to_integer(id))
    links = Koko.Archive.Item.links_for_document(document)

    conn |> render("index.html", links: links, title: document.title)

  end

  def show(conn, %{"id" => id}) do
    IO.puts "THIS IS ARCHIVE.SHOW, id = #{id}"
    item = Repo.get(Item, String.to_integer(id))
    IO.inspect item
    document = Repo.get(Document, item.doc_id)
    version_string = item.version |> Integer.to_string
    archive = Repo.get(Archive, item.archive_id)
    IO.inspect archive
    reply = Koko.Archive.Item.get_archived_item(archive, item)
    conn |> render("show.html", text: reply, version: version_string,
             title: document.title, remarks: item.remarks)
  end


  def create(conn, %{"id" => id}) do
    IO.puts "This is CREATE ARCHIVE"
    IO.inspect Token.user_id_from_header(conn)
    with  {:ok, user_id} <- Token.user_id_from_header(conn),
      IO.puts "INSIDE WITH"
      # { :ok, %Archive{} = archive} <- DocManager.create_document(document_params, user_id)
    do
      conn
      |> put_status(:created)
      |> render("create_archive.html", id: id, user_id: user_id)
    else
      {:error, error} -> {:error, error}
    end
  end

  # Create an archive (repository)
  def new_repository(conn, %{"user_id" => user_id, "name" => name}) do
    IO.puts "This is CREATE REPOSITORY for user #{user_id} with name #{name}"

    with {:ok, user} <- User.get_user(user_id),
    {:ok, archive} <- Archive.create(Koko.Configuration.bucket, name, user_id, "OK")
    do
      conn
      |> put_status(:created)
      |> render("create_repository.html", user_id: user_id, username: user.username, name: name)
    else
      {:error, error} -> conn |> render("create_repository_error.html", user_id: user_id)
    end
  end

  # Create an new archive of a document
  def new_version(conn, %{"doc_id" => doc_id}) do
    IO.puts "This is CREATE NEW ARCHIVE FOR FILE #{doc_id}"

    with {:ok, document} <- Document.get_document(doc_id)
    do
      [bucket, archive_name] = Koko.Archive.Item.archive_document(document, "ok")
      version = Document.get_version(document) + 1
      title = document.title
      characters = String.length(document.content)
      
      # |> render("archive_document.html", doc_id: doc_id, title: title,
      #    version: version, characters: characters, bucket: bucket, archive_name: archive_name)

      document = Repo.get(Document, String.to_integer(doc_id))
      links = Koko.Archive.Item.links_for_document(document)
  
      conn
      |> put_status(:created)
      |> render("index.html", links: links, title: document.title)
    else
      {:error, error} -> conn |> render("archive_document_error.html",
         doc_id: doc_id )
    end
  end



end
