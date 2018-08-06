defmodule Koko.Web.PublicDocumentController do
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

  alias Koko.Document.DocManager
  alias Koko.Document.Document
  alias Koko.Document.MasterDocument
  alias Koko.User.Token
  alias Koko.Document.Search
  alias Koko.Repo

  action_fallback Koko.Web.FallbackController

  @doc """
  All public documents are listable and searchable.
  """
  def index(conn, _params) do
    IO.puts "PUBLIC DOC CONTROLLER"
    query_string =  case conn.query_string do
        nil -> "title=xy78837493kfe!gjj!"
        "" ->  "title=xy78837493kfe!gjj!"
        _ -> conn.query_string
      end
    
    master_document_id = MasterDocument.get_master_doc_id(query_string)
    api_version = api_version_from_headers(conn)
    IO.puts "api_version : #{api_version}"
    cond do
      master_document_id > 0 ->
        documents = DocManager.list_children(:public, master_document_id)
      String.contains? query_string, "random=public" ->
        documents = Search.random_public query_string
      String.contains? query_string, "random=all" ->
        documents = Search.random query_string
      String.contains? query_string, "random_user" ->
          documents = Search.random_user query_string
      String.contains? query_string, "idlist" ->
          documents = Search.idlist query_string
      true ->
        documents = Search.by_query_string(:document, query_string, ["public=yes" ,"limit=#{Search.search_limit()}"])
    end
    IO.puts "#{length documents} documents found"
    case api_version do 
      "V1" -> render(conn, "index.json", documents: documents)
      "V2" -> render(conn, "indexV2.json", documents: documents) 
      _ -> render(conn, "error.json", error: "Unknown API")
    end
  end

  @doc """
  All public documents are readable/displayble.
  """
  def show(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    api_version = IO.inspect api_version_from_headers(conn), label: "api version"
    if document.attributes["public"] == true do
      cs = Document.changeset(document, %{viewed_at: DateTime.utc_now()})
      Repo.update(cs)
      case api_version do 
        "V1" -> render(conn, "show.json", document: document)
        "V2" -> render(conn, "showV2.json", document: document) 
        _ -> render(conn, "error.json", error: "Unknown API")
      end
      
    else
      {:error, "Cannot display document"}
    end
  end

  def request_header_map(conn) do
    Enum.into conn.req_headers, %{}
  end

  def api_version_from_headers(conn) do 
    request_header_map(conn)["apiversion"] || "V1"
  end

end
