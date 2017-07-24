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
    docs = Search.by_query_string("author=#{user_id}")
    IO.puts "#{length docs} User docs found"
    docs
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
      Map.merge(attrs, %{"author_id" => author_id, "parent_id" => 0})
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

      iex> update_document(document, %{field: new_value}, "")
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value}, "")
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs, query_string) do
    default_attrs = %{ "attributes" => Document.default_attributes }
    attrs =
      Map.merge(default_attrs, attrs)
    document
      |> Document.changeset(attrs)
      # |> render(document)
      |> Document.update_identifier(document)
      |> MasterDocument.set_children(document)
      |> Repo.update()
    if document.attributes["doc_type"] == "master" do
      IO.puts "I AM GOING TO SET LEVEL OF CHILDREN ..."
      update_child_levels(document)
    end
    if query_string != "" do
      execute_query_string_commands(document, query_string)
    end
    # if query_string == "adopt_children=yes" do
    #   MasterDocument.adopt_children(document)
    # end
    {:ok, document}
  end

  def execute_query_string_commands(document, query_string) do
    IO.puts "execute_query_string_commands: #{query_string}"
    [command|remaining_commands] = String.split(query_string, "&") |> Enum.map(fn(item) -> String.split(item, "=") end)
    [cmd, arg] = command
    case cmd do
      "adopt_children" ->
         MasterDocument.adopt_children(document)
      "attach" ->
         MasterDocument.attach(document, arg, remaining_commands)
      _ ->
        IO.puts "query string #{query_string} for #{document.id} (#{document.title}) not recognized"   
    end
  end

  def update_child_levels(document) do
    IO.puts "... SETTING LEVEL OF CHILDREN"
    document.children
    |> Enum.map(fn(child) -> Document.set_level_of_child(child) end)
  end

  def render(:master, changeset, document) do
    [rendered_content|_] = String.split(document.content, "TOC:\n")
    IO.puts "RC: #{rendered_content}"
    Ecto.Changeset.put_change(changeset, :rendered_content, rendered_content)
  end

  def render(:latex, changeset, document) do
    rendered_content = Regex.replace(~r/%.*$/m, document.content, "")
      # String.split(document.content, ["\n", "\r", "\r\n"])
      # |> Enum.filter(fn(line) -> !(line =~ ~r/^%.*/) end)
      # |> Enum.join("\n")
    IO.puts "\n==========\nLATEX CONTENT: #{rendered_content}\n==========\n"
    Ecto.Changeset.put_change(changeset, :rendered_content, rendered_content)
  end

  def render(changeset, document) do
    dt = document.attributes["doc_type"]
    IO.puts "render, doc_type = #{dt}"
    cond do
      document.attributes["doc_type"] == "master"  ->
        render(:master, changeset, document)
      document.attributes["text_type"] == "latex"  ->
        render(:latex, changeset, document)
      true ->
        rendered_content = document.content
        Ecto.Changeset.put_change(changeset, :rendered_content, rendered_content)
    end
  end




  # Assume a comma or space separated string
  def update_tags_with_string(document, str) do
     tags = Regex.split(~r/[, ]/, str) |> Enum.filter(fn(item) -> item != "" end) |> Enum.map(fn(item) -> String.trim(item) end )
     update_document(document,%{"tags" => tags}, "")
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
