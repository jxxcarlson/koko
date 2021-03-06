defmodule Koko.Document.DocManager do
  @moduledoc """
  The boundary for the DocManager system.
  """

  import Ecto.Query, warn: false
  alias Koko.Repo

  alias Koko.Document.Document
  alias Koko.Document.DocManager
  alias Koko.Document.MasterDocument
  alias Koko.Document.Search
  alias Koko.Document.Query
  alias Koko.User.User

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
    Search.by_query_string(:document, "author=#{user_id}", [])
  end


  def list_children(:generic, user_id, id) do
    master_document = Repo.get(Document, id)
    if master_document.attributes["public"] do
      list_children(:public, id)
    else
      list_children(:user, user_id, id)
    end
  end

  def list_children(:public, id) do
    master_document = Repo.get(Document, id)
    cond do
      master_document == nil ->
        []
      # master_document.attributes["public"] == true ->
      #  list_children_aux(:public, master_document)
      true -> list_children_aux(:public, master_document)
    end
  end

  def list_children(:user, user_id, id) do
    master_document = Repo.get(Document, id)
    cond do
      master_document == nil ->
        []
      master_document.author_id == user_id ->
        list_children_aux(:user,  master_document)
      true ->
        []
    end
  end

  defp list_children_aux(:public, master_document) do
    Enum.reduce master_document.children,
      [master_document],
      fn(child, acc) -> acc ++ getChild(:public, child) end
  end

  defp list_children_aux(:user, master_document) do
    Enum.reduce master_document.children,
      [master_document],
      fn(child, acc) -> acc ++ getChild(:private, child) end
  end

  defp getChild(:public, child) do
    doc = Repo.get(Document, child.doc_id)
    cond do
      doc == nil -> []
      doc.attributes["public"] == false -> []
      true -> [doc]
    end
  end

  defp getChild(:private, child) do
    doc = Repo.get(Document, child.doc_id)
    cond do
      doc == nil -> []
      true -> [doc]
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

  # Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs, author_id) do
    IO.puts "doc manager, CREATE DOCUMENT"
    author = Repo.get(User, author_id)
    complete_attributes = Map.merge Document.default_attributes, (attrs["attributes"] || %{})
    additional_attrs = %{ "attributes" => complete_attributes,
      "author_id" => author_id, "author_name" => author.username }
    attrs = Map.merge(attrs, additional_attrs)
    result = %Document{}
      |> Document.changeset(attrs)
      |> Repo.insert()
    {:ok, doc} = result
    IO.puts "New document id = #{doc.id}"
    IO.puts "Parent document id = #{doc.parent_id}"
    IO.puts "DOC CONTENT: #{doc.content}"
    last_word = doc.content |> String.split(" ") |> Enum.reverse |> hd
    if String.contains?  last_word, ":" do
      target_doc_id_string = last_word |> String.split(":") |> tl |> hd
    end

    # THE FUNCIONALITY COMMENTED OUT IS TAKEN CARE OF
    # IN doc_manager.execute_query_string_commands
    #
    # if doc.parent_id > 0 do
    #   IO.puts "EXECUTE QUERY STRING (ATTACH : 1)"
    #   master_doc = Repo.get(Document, doc.parent_id)
    #   if String.contains?  last_word, ":" do
    #     target_doc_id_string = last_word |> String.split(":") |> tl |> hd
    #     MasterDocument.attach!(master_doc, "below", [["child", "#{doc.id}"], ["current", target_doc_id_string]])
    #   else
    #     MasterDocument.attach!(master_doc, "at-bottom", [["child", "#{doc.id}"]])
    #   end
    # end
    case result  do
      {:ok, doc} ->
        Document.set_identifier(doc)
      {:error, _} ->
        IO.puts "Could not create document"
    end
  end

  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

 ## image::https://s-media-cache-ak0.pinimg.com/originals/d1/a1/30/d1a13095ebb82938328de77468ef1c29.jpg[width=100%]

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value}, "")
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value}, "")
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs, query_string) do
    IO.puts "*** Enter update_document, query_string = #{query_string}"
    default_attrs = %{ "attributes" => Document.default_attributes }
    attrs =
      Map.merge(default_attrs, attrs)
    document
      |> Document.changeset(attrs)
      # |> render(document)
      |> Document.update_identifier(document)
      |> Document.update_viewed_at
      |> MasterDocument.set_children_from_content(document, attrs["content"])
      |> MasterDocument.update_text_from_children(document, attrs["content"])
      |> Repo.update()
    if document.attributes["doc_type"] == "master" do
      update_child_levels(document)
      MasterDocument.adopt_children(document)
      new_document = DocManager.get_document!(document.id)
      MasterDocument.update_levels(document.children, new_document.children)
    end

    # This is where additional processing, e.g., attaching a
    # document to a master document, occurs
    if query_string != "" do
      execute_query_string_commands(document, query_string)
    end
    # if query_string == "adopt_children=yes" do
    #   MasterDocument.adopt_children(document)
    # end
    {:ok, document}
  end

  def execute_query_string_commands(document, query_string) do
    [command|remaining_commands] = String.split(query_string, "&") |> Enum.map(fn(item) -> String.split(item, "=") end)
    IO.inspect [command|remaining_commands], label: "[command|remaining_commands]"
    IO.puts "EXECUTE QUERY STRING (ATTACH : 2)"
    [cmd, arg] = command
    case cmd do
      "adopt_children" ->
         MasterDocument.adopt_children(document)
      "attach" ->
         master = MasterDocument.attach!(document, arg, remaining_commands)
         content = MasterDocument.updated_text_from_children(master.content, master.children)
         changeset = Document.changeset master, %{"content" => content}
         Repo.update(changeset)
      _ ->
        IO.puts "query string #{query_string} for #{document.id} (#{document.title}) not recognized"
    end
  end

  def update_child_levels(document) do
    document.children
    |> Enum.map(fn(child) -> Document.set_level_of_child(child) end)
  end

  def render(:master, changeset, document) do
    [rendered_content|_] = String.split(document.content, MasterDocument.table_of_contents_separator())
    Ecto.Changeset.put_change(changeset, :rendered_content, rendered_content)
  end

  def render(:latex, changeset, document) do
    rendered_content = Regex.replace(~r/%.*$/m, document.content, "")
      # String.split(document.content, ["\n", "\r", "\r\n"])
      # |> Enum.filter(fn(line) -> !(line =~ ~r/^%.*/) end)
      # |> Enum.join("\n")
    Ecto.Changeset.put_change(changeset, :rendered_content, rendered_content)
  end

  def render(changeset, document) do
    dt = document.attributes["doc_type"]
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

  def add_notes_for_user(user_id) do
    author = Repo.get(User, user_id)
    complete_attributes = Document.default_attributes
    attrs_1 = %{ "attributes" => complete_attributes, "author_id" => user_id, "author_name" => author.name }
    other_attrs = %{
       "tags" => ["sidebarNotes"],
       "title" => "Notes",
       "content" => "Your notes here",
       "rendered_content" => "Your notes here"
    }
    attrs = Map.merge(attrs_1, other_attrs)
    create_document(attrs, user_id)
  end

  def add_notes_for_all_users do
    User |> Repo.all |> Enum.each(fn(user) -> add_notes_for_user(user.id) end)
  end

end
