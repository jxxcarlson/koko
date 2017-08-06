defmodule Koko.Web.DocumentController do
  use Koko.Web, :controller

  @moduledoc """
  The actions in this module, with the exception of
  `index_public` and `show_public`, are accesible
  to users only if they present a valid token.
  For instance, the `index` action is guarded in this way.
  Moreover, it will only display the user's documents.
  (or public documents, one uses `index_public`).  Likewise,
  a document can be deleted only by its owner, and newly
  created documents are automatically assigned to the user
  listed in the token.

  See REST_API.adoc for documetation of the requests (header,
  route, body) as well as the form of the reply.
  """

  alias Koko.DocManager
  alias Koko.DocManager.Document
  alias Koko.Authentication.Token
  alias Koko.DocManager.Search
  alias Koko.Repo

  action_fallback Koko.Web.FallbackController

  @doc """
  List and search for documents owned by the user
  defined in the token.
  """
  def index(conn, _params) do
    IO.puts "INDEX __"
    with {:ok, user_id} <- Token.user_id_from_header(conn)
      do
        cond do
          conn.query_string =~ ~r/^master=/ ->
            [_, id] = String.split(conn.query_string, "=")
            master_document_id = String.to_integer id
            documents = DocManager.list_children(:user, user_id, master_document_id)
          conn.query_string == "all" ->
            documents = DocManager.list_documents(:user, user_id)
          true ->
            documents = Search.by_query_string_for_user(conn.query_string, user_id)
        end
        render(conn, "index.json", documents: documents)
        else
        _ -> IO.puts "Error getting documents; "; {:error, "Not authorized"}

      end
  end

  @doc """
  All public documents are listable and searchable.
  """
  def index_public(conn, _params) do
      IO.puts "INDEX PUBLIC"
    cond do
      conn.query_string =~ ~r/^master=/ ->
        [_, id] = String.split(conn.query_string, "=")
        documents = DocManager.list_children(:public, id)
      conn.query_string == "all" || conn.query_string == "public=yes&limit=30" ->
        documents = DocManager.list_documents(:public)
      true ->
        documents = Search.by_query_string(conn.query_string <> "&public=yes&limit=30")
    end
    render(conn, "index.json", documents: documents)
  end


  # {:ok, user_id} <- Token.get_user_id_from_header(conn),

  @doc """
  To create a document, the user must present a token.  The user_id
  information in that token is used to define ownership of the document.
  """
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
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Display a document if it is owned by the user defined by the token.
  """
  def show(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    with {:ok, user_id} <- Token.user_id_from_header(conn),
      true <- ((document.attributes["public"] == true) || (user_id == document.author_id))
    do
      cs = Document.changeset(document, %{})
      |> Document.update_viewed_at
      Repo.update(cs)
      IO.puts "XXXXX: #{document.title} viewed at #{DateTime.utc_now()}"
      render(conn, "show.json", document: document)
      else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  All public documents are readable/displayble.
  """
  def show_public(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    if document.attributes["public"] == true do
      cs = Document.changeset(document, %{viewed_at: DateTime.utc_now()})
      IO.puts "#{document.title} viewed at #{DateTime.utc_now()}"
      Repo.update(cs)
      render(conn, "show.json", document: document)
    else
      {:error, "Cannot display document"}
    end
  end

  defp match_integers(a, b, success_message, failure_message) do
    if a == b do
      {:ok, success_message}
    else
      {:error, failure_message}
    end
  end

  @doc """
  A user can only update the documents he owns.
  """
  def update(conn, %{"id" => id, "document" => payload}) do

    document_params = Koko.Utility.project2map(payload)
    document = DocManager.get_document!(id)
    # failure_message = "User id and document author id do not match"

    with {:ok, user_id} <- Token.user_id_from_header(conn),
      {:ok, "match"} <- match_integers(user_id, document.author_id, "match", "couldn't match #{user_id} with #{document.author_id}"),
      {:ok, %Document{} = document} <- DocManager.update_document(document, document_params, conn.query_string)
    do
      render(conn, "show.json", document: document)
    else
      {:error, error} -> {:error, error} #{ }"error: #{error}"
    end

  end

  @doc """
  A user can only delete the documents he owns.
  """
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
