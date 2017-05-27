defmodule Koko.Web.DocumentController do
  use Koko.Web, :controller

  alias Koko.DocManager
  alias Koko.DocManager.Document

  action_fallback Koko.Web.FallbackController

  def index(conn, _params) do
    documents = DocManager.list_documents()
    render(conn, "index.json", documents: documents)
  end

  def create(conn, %{"document" => payload}) do
    document_params = Koko.Utility.project2map(payload)
    with {:ok, %Document{} = document} <- DocManager.create_document(document_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", document_path(conn, :show, document))
      |> render("show.json", document: document)
    end
  end

  def show(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    render(conn, "show.json", document: document)
  end

  def update(conn, %{"id" => id, "document" => payload}) do

    document_params = Koko.Utility.project2map(payload)
    document = DocManager.get_document!(id)

    with {:ok, %Document{} = document} <- DocManager.update_document(document, document_params) do
      render(conn, "show.json", document: document)
    end
  end

  def delete(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    with {:ok, %Document{}} <- DocManager.delete_document(document) do
      send_resp(conn, :no_content, "")
    end
  end
end