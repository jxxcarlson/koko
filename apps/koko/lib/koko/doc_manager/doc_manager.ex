defmodule Koko.DocManager do
  @moduledoc """
  The boundary for the DocManager system.
  """

  import Ecto.Query, warn: false
  alias Koko.Repo

  alias Koko.DocManager.Document
    alias Koko.DocManager.MasterDocument
  alias Koko.DocManager.Search
  alias Koko.DocManager.Query

  @doc """
  Returns the list of documents.

  ## Examples

      iex> list_documents()
      [%Document{}, ...]

  """
  def list_documents do
    Repo.all(Document)
  end

  def list_documents(:public) do
    Document |> Query.is_public |> Query.sort_by_updated_at |> Repo.all
  end

  def list_documents(:user, user_id) do
    Search.by_query_string("author=#{user_id}")
  end

  def list_children(:public, id) do
    master_document = Repo.get(Document, id)
    cond do
      master_document == nil ->
        []
      master_document.attributes["public"] == true ->
        list_children(master_document)
      true ->
        []
    end
  end

  def list_children(:user, id, user_id) do
    master_document = Repo.get(Document, id)
    cond do
      master_document == nil ->
        []
      master_document.author_id == user_id ->
        list_children(master_document)
      true ->
        []
    end
  end

  defp list_children(master_document) do
    Enum.reduce master_document.children,
      [master_document],
      fn(child, acc) -> acc ++ getChild(child) end
  end

  defp getChild(child) do
    doc = Repo.get(Document, child.doc_id)
    if doc == nil do
      []
    else
      [doc]
    end
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id), do: Repo.get!(Document, id)

  @doc """
  Creates a document.

  ## Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs, author_id) do
    attrs =
      Map.merge(attrs, %{"author_id" => author_id})
      |> Map.merge(%{ "attributes" => Document.default_attributes })
      |> Map.merge(%{ "tags" => []})
    IO.inspect attrs
    result = %Document{}
      |> Document.changeset(attrs)
      |> Repo.insert()
    case result  do
      {:ok, doc} ->
        Document.set_identifier(doc)
      {:error, error} ->
        IO.puts "Could not create document"
    end
  end

  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end


  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    default_attrs = %{ "attributes" => Document.default_attributes }
    attrs =
      Map.merge(default_attrs, attrs)
    document
      |> Document.changeset(attrs)
      |> render(document)
      |> Document.update_identifier(document)
      |> MasterDocument.set_children(document)
      |> Repo.update()
  end

  def render(changeset, document) do
    if document.attributes["doc_type"] == "master" do
      [rendered_content|_] = String.split(document.content, "TOC:\n")
      IO.puts "RC: #{rendered_content}"
      Ecto.Changeset.put_change(changeset, :rendered_content, rendered_content)
    else
      rendered_content = document.content
      Ecto.Changeset.put_change(changeset, :rendered_content, rendered_content)
    end
  end



  # Assume a comma or space separated string
  def update_tags_with_string(document, str) do
     tags = Regex.split(~r/[, ]/, str) |> Enum.filter(fn(item) -> item != "" end) |> Enum.map(fn(item) -> String.trim(item) end )
     update_document(document,%{"tags" => tags})
  end



  @doc """
  Deletes a Document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{source: %Document{}}

  """
  def change_document(%Document{} = document) do
    Document.changeset(document, %{})
  end

end
