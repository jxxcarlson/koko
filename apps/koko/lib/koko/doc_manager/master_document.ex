
# alias Koko.DocManager.MasterDocument; MasterDocument.parse_line("This is   a test")
defmodule Koko.DocManager.MasterDocument do

  alias Koko.Repo
  alias Koko.DocManager.Document

  # alias Koko.Repo; alias Koko.DocManager.Document
  # alias Koko.DocManager.MasterDocument; MasterDocument.parse_line({"== 1", 33})


  def parse(document) do
    parse_string(document.content)
  end


  def set_children(changeset, document) do
    if document.attributes["doc_type"] == "master" do
      children = parse(document)
        |> Enum.filter(fn(item) -> is_valid(item) end)
        |> Enum.map(fn(item) -> get_item(item) end)
      Ecto.Changeset.put_embed(changeset, :children, children)
    else
      changeset
    end
  end

  def is_valid(item) do
    case item do
      {:item, _, _} ->  true
      _ -> false
    end
  end

  def get_item(item) do
    {:item, _, ii} = item
    ii
  end

  def rewrite(parsed_document) do
    parsed_document |> Enum.reduce("", fn (item, acc) -> acc <> string_of(item) end)
  end

  def string_of_level(level) do
    Enum.reduce 1..level, "", fn(_, acc) -> "=" <> acc end
  end

  def string_of(item) do
    case item do
      {:error, line_number, message, line} -> "// Error at line #{line_number} (#{message}): #{line}\n"
      {:comment, _, line} -> line <> "\n"
      {:item, _, ii} -> "#{string_of_level(ii.level)} #{ii.doc_id} #{ii.title} #{ii.comment}\n"
    end
  end

  def parse_string(input) do
    [a|b] = String.split(input, "TOC:\n")
    if b == [] do
      str = a
    else
      str = b |> hd
    end

    String.split(str, ["\n", "\r", "\r\n"])
      |> Enum.map(fn(line) -> String.trim(line) end)
      |> Enum.with_index(1)
      |> Enum.map(fn(item) -> parse_line(item) end)
  end

  defp parse_line(item) do
    {line, line_number} = item
    words = line |> String.split(" ")
      |> Enum.filter fn(word) -> word != "" end
    cond do
      length(words) == 0 ->
        {:blank, line_number, ""}
      hd(words) =~ ~r/^=*$/ ->
        parse_item(words, line_number, line)
      hd(words) == "//" ->
        {:comment, line_number, line}
      true ->
        {:error, line_number, ["unrecognized line", line]}
    end
  end



  defp get_id(words) do
    if words == [] do
        {:error, "No document ID"}
    else
      result =  words |> hd |> Integer.parse
      if result == :error do
        {:error, "Second word is not a document ID"}
      else
        {id, _} = result
        {:ok, id}
      end
    end
  end

  defp get_document(id) do
    result = Repo.get(Document, id)
    if result == nil do
      {:error, "Document #{id} not found"}
    else
      {:ok, result}
    end
  end

  defp parse_item(words, line_number, line) do
    [firstWord|tail] = words
    level = String.length firstWord

    [_|tail2] = String.split(line, "//")
    if tail2 == [] do
      comment = ""
    else
      comment = tail2 |> hd |> String.trim
    end

    with {:ok, id} <- get_id(tail),
      {:ok, document} <- get_document(id)
    do
      toc_item = %Child{doc_id: id, level: level,
        title: document.title, doc_identifier: document.identifier,
        comment: comment}
      {:item, line_number, toc_item}
    else
      err -> {:error, line_number, "Bad line", line}
    end

  end

  def stringOfChild(child) do
    "#{string_of_level(child.level)} #{child.doc_id} #{child.title} // #{child.comment}\n"
  end

  def updated_text(document) do
    [text1, _] = String.split(document.content, "TOC:\n")
    text2 = Enum.reduce(document.children, "", fn(child, acc) -> acc <> stringOfChild(child) end)
    text1 <> "\nTOC:\n" <> text2
  end

  ############

  def adopt_children(master_document) do
    master_document.children
    |> Enum.map( fn(child) -> Document.set_parent(Document.child_document(child), master_document.id) end)
  end

  def attach(document, position, remaining_commands) do

    [child_command|remaining_commands] = remaining_commands
    ["child", child_id_str] = child_command # error handling
    child_id = String.to_integer(child_id_str)
    child_document = Repo.get(Document, child_id)

    new_child = %Child{doc_id: child_id, level: 2,
      title: child_document.title, doc_identifier: child_document.identifier,
      comment: "comment"}

    Document.set_parent(Document.child_document(new_child), document.id)

    children = case position do
      "at-top" ->
        [new_child] ++ document.children
      "at-bottom" ->
        document.children ++ [new_child]
      "above" ->
        ["current", current_id] = (hd remaining_commands)
        k = index_of_child_with_id(document.children, String.to_integer(current_id))
        insert_before(new_child, k, document.children)
      "below" ->
        ["current", current_id] = (hd remaining_commands)
        k = index_of_child_with_id(document.children, String.to_integer(current_id))
        insert_after(new_child, k, document.children)
      _ ->
        document.children
    end

    doc = Document.update_children(document, children)
    new_content = updated_text(doc)
    cs = Document.changeset(doc, %{content: new_content})
    Repo.update!(cs)
  end

  def index_of_child_with_id(children, id) do
    Enum.find_index(children, fn(child) -> child.doc_id == id end)
  end

  def insert_before(item, position, items) do
    Enum.take(items, position) ++ [item] ++ Enum.drop(items, position)
  end

  def insert_after(item, position, items) do
    Enum.take(items, position+1) ++ [item] ++ Enum.drop(items, position+1)
  end

end
