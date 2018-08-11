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

  alias Koko.Document.DocManager
  alias Koko.Document.Document
  alias Koko.Document.MasterDocument
  alias Koko.User.Token
  alias Koko.Document.Search
  alias Koko.Repo
  alias Koko.Document.Access

  action_fallback Koko.Web.FallbackController

  @doc """
  List and search for documents owned by the user
  defined in the token.
  """
  def index(conn, _params) do
    query_string = conn.query_string || "" 
    IO.puts "DC, QUERY STRING = #{query_string}"
    api_version = api_version_from_headers(conn)
    with {:ok, user_id} <- Token.user_id_from_header(conn)
      do
          master_document_id =  MasterDocument.get_master_doc_id(conn.query_string)
          {:ok, username} = Token.username_from_header(conn)
          cond do
            String.contains? query_string, "random=public" ->
              documents = Search.random_public query_string
            String.contains? query_string, "random=all" ->
              documents = Search.random query_string
            String.contains? query_string, "random_user" ->
                documents = Search.random_user query_string
            String.contains? query_string, "idlist" ->
                documents = Search.idlist query_string
            String.contains? query_string, "shared_only=yes" ->
                   documents = Search.by_query_string(:document, remove_string("&shared_only=yes", query_string),
                      ["shared_only_with=#{user_id},#{username}" ])
            String.contains? query_string, "shared=yes" ->
                documents = Search.by_query_string(:document, remove_string("&shared=yes", query_string),
                   ["shared_with=#{user_id},#{username}" ])
            master_document_id > 0 ->
              documents = DocManager.list_children(:generic, user_id, master_document_id)
            true ->
              documents = Search.get_documents_for_user(user_id, conn.query_string, [])
           end
           if String.contains?  query_string, "loading" do
             render(conn, "index_loading.json", documents: documents)
           else
            case api_version do 
              "V1" -> render(conn, "index.json", documents: documents)
              "V2" -> render(conn, "indexV2.json", documents: documents) 
              _ -> render(conn, "error.json", error: "Unknown API")
            end
           end
      else
        _ -> IO.puts "Error getting documents (not authorized) "; {:error, "Not authorized"}
      end
  end


  def remove_string(str, target) do
      String.replace target, str, ""
  end



  # {:ok, user_id} <- Token.get_user_id_from_header(conn),

  @doc """
  To create a document, the user must present a token.  The user_id
  information in that token is used to define ownership of the document.
  """
  def create(conn, %{"document" => payload}) do
    api_version = api_version_from_headers(conn)
    document_params = Koko.Utility.project2map(payload)
    with  {:ok, user_id} <- Token.user_id_from_header(conn),
      {:ok, %Document{} = document} <- DocManager.create_document(document_params, user_id)
    do
      conn
      |> put_status(:created)
      |> put_resp_header("location", document_path(conn, :show, document))
      case api_version do 
        "V1" -> render(conn, "show.json", document: document)
        "V2" -> render(conn, "documentRecordV2.json", document: document)
        _ -> render(conn, "error.json", error: "Unknown API")
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Display a document if it is owned by the user defined by the token.
  """
  def show(conn, %{"id" => id}) do
    api_version = api_version_from_headers(conn)
    document = DocManager.get_document!(id)
    
    with {:ok, user_id} <- Token.user_id_from_header(conn),
      true <- ((document.attributes["public"] == true) || (user_id == document.author_id))
    do
      cs = Document.changeset(document, %{})
      |> Document.update_viewed_at
      Repo.update(cs)
      case api_version do 
        "V1" -> render(conn, "show.json", document: document)
        "V2" -> render(conn, "documentRecordV2.json", document: document)
        _ -> render(conn, "error.json", error: "Unknown API")
      end
      else
      {:error, error} -> {:error, error}
    end
  end

  def request_header_map(conn) do
    Enum.into conn.req_headers, %{}
  end

  def api_version_from_headers(conn) do 
    request_header_map(conn)["apiversion"] || "V1"
  end

  defp match_items(a, b, success_message, failure_message) do
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
    api_version = api_version_from_headers(conn)
    document_params = Koko.Utility.project2map(payload)
    document = DocManager.get_document!(id)
    # failure_message = "User id and document author id do not match"

    with {:ok, user_id} <- Token.user_id_from_header(conn),
      {:ok, username} <- Token.username_from_header(conn),
      {:ok, _} <- authorize_update(document, user_id, username),
      {:ok, %Document{} = document} <- DocManager.update_document(document, document_params, conn.query_string)
    do
      case api_version do 
        "V1" -> render(conn, "show.json", document: document)
        "V2" -> render(conn, "documentRecordV2.json", document: document)
        _ -> render(conn, "error.json", error: "Unknown API")
      end
      
    else
      {:error, error} -> {:error, error} #{ }"error: #{error}"
    end

  end

  def share(conn, %{"id" => id, "username" => username, "action" => action}) do
    document = DocManager.get_document!(id)
    with {:ok, user_id} <- Token.user_id_from_header(conn)
    do
        Access.set_user_access(document, username, action)
        render(conn, "show.json", document: document)
    else
        {:error, error} -> {:error, error} #{ }"error: #{error}"
    end
  end


  defp authorize_update(document, user_id, username) do
    cond do
      document.id == user_id -> {:ok, "user owns document"}
      Access.shared_access_granted(document, user_id, username, :write) == true -> {:ok, "document is shared with user"}
      true -> {:error, "not authorized"}
    end
  end

  @doc """
  A user can only delete the documents he owns.
  """
  def delete(conn, %{"id" => id}) do
     api_version = api_version_from_headers(conn)
     document = DocManager.get_document!(id)
     with {:ok, user_id} <- Token.user_id_from_header(conn),
      true <- user_id == document.author_id,
      {:ok, %Document{}} <- DocManager.delete_document(document)
     do
      case api_version do 
        "V1" -> send_resp(conn, :no_content, "")
        "V2" -> render(conn, "reply.json", reply: "#{id}")
        _ -> render(conn, "error.json", error: "Unknown API")
      end
     else
      _ -> {:error, "Could not delete document"}
     end
   end

end
