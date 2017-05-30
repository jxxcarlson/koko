defmodule Koko.Web.DocumentController do
  use Koko.Web, :controller

  alias Koko.DocManager
  alias Koko.DocManager.Document
  alias Koko.Authentication.Token

  action_fallback Koko.Web.FallbackController

  def index(conn, _params) do
    with {:ok, user_id} <- Token.user_id_from_header(conn)
    do
      documents = DocManager.list_documents(user_id)
      render(conn, "index.json", documents: documents)
    else
      _ -> {:error, "Not authorized"}
    end
  end

  def index_public(conn, _params) do
    documents = DocManager.list_documents(:public)
    render(conn, "index.json", documents: documents)
  end


# {:ok, user_id} <- Token.get_user_id_from_header(conn),

  def create(conn, %{"document" => payload}) do
    document_params = Koko.Utility.project2map(payload)
    with  {:ok, user_id} <- Token.user_id_from_header(conn),
          {:ok, %Document{} = document} <- DocManager.create_document(document_params, user_id)
    do
      conn
      |> put_status(:created)
      |> put_resp_header("location", document_path(conn, :show, document))
      |> render("show.json", document: document)
    else
      {:error, error} -> "error: #{error}"
    end
  end

  def show(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    with {:ok, user_id} <- Token.user_id_from_header(conn),
         true <- ((document.attributes["public"] == true) || (user_id == document.author_id))
    do
      render(conn, "show.json", document: document)
    else
      err -> {:error, "Cannot display document"}
    end
  end

  def show_public(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    if document.attributes["public"] == true do
      render(conn, "show.json", document: document)
    else
        {:error, "Cannot display document"}
    end
  end

  def update(conn, %{"id" => id, "document" => payload}) do

    document_params = Koko.Utility.project2map(payload)
    document = DocManager.get_document!(id)
    IO.puts "START"
    with {:ok, message} <- Koko.Utility.ok_message("(0)"),
        {:ok, user_id} <- Token.user_id_from_header(conn),
         {:ok, message} <- Koko.Utility.ok_message("(1)"),
         true <- user_id == document.author_id,
         {:ok, message} <- Koko.Utility.ok_message("(2)"),
         {:ok, %Document{} = document} <- DocManager.update_document(document, document_params),
         {:ok, message} <- Koko.Utility.ok_message("(3)")
    do
      IO.puts "WE ARE HERE"
      render(conn, "show.json", document: document)
    else
      _ -> {:error, "Could not update document"}
    end
  end

  def delete(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    with {:ok, user_id} <- Token.user_id_from_header(conn),
         true <- user_id == document.author_id,
         {:ok, %Document{}} <- DocManager.delete_document(document)
    do
      send_resp(conn, :no_content, "")
    else
      _ -> {:error, "Could not delete document"}
    end
  end
end
