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
    query_string = conn.query_string || "" |> IO.inspect(label: "Public Doc Controller, QUERYSTRING")
    master_document_id = MasterDocument.get_master_doc_id(query_string)
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
    render(conn, "index.json", documents: documents)
  end

  @doc """
  All public documents are readable/displayble.
  """
  def show(conn, %{"id" => id}) do
    document = DocManager.get_document!(id)
    if document.attributes["public"] == true do
      cs = Document.changeset(document, %{viewed_at: DateTime.utc_now()})
      Repo.update(cs)
      render(conn, "show.json", document: document)
    else
      {:error, "Cannot display document"}
    end
  end

end
