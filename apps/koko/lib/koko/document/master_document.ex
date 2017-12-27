
# alias Koko.DocManager.MasterDocument; MasterDocument.parse_line("This is   a test")
defmodule Koko.Document.MasterDocument do

  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Document.DocManager

  # alias Koko.Repo; alias Koko.DocManager.Document
  # alias Koko.DocManager.MasterDocument; MasterDocument.parse_line({"== 1", 33})


  def get_master_doc_id(query_string) do
    qs = query_string || ""
    (Regex.run(~r/master=\d+/, qs) || ["master=0"])
    |> hd
    |> String.split("=")
    |> Enum.at(1)
    |> String.to_integer
  end


  def parse(content) do
    parse_string(content)
  end

  def set_defaults(changeset, _document) do
    # if document.attributes["doc_type"] == "master" do
    #   if !String.contains?(document.content, table_of_contents_separator()) do
    #     Document.changeset(document, %{content: document.content <> "\n" <> table_of_contents_separator()})
    #   end
    # else
    #   changeset
    # end
    changeset
  end

  # XXX: Last change
  def set_children_from_content(changeset, document, content) do
    IO.puts "In set_children_from_content, doc_type = #{document.attributes["doc_type"]}"
    IO.inspect changeset, label: "INITIAL CHANGESET"
    old_children = document.children
    if document.attributes["doc_type"] == "master" do
      IO.puts "MAIN BRANCH ..."
      children = parse(content)
        |> Enum.filter(fn(item) -> is_valid(item) end)
        |> Enum.map(fn(item) -> get_item(item) end)
      {children, Ecto.Changeset.put_embed(changeset, :children, children)}
    else
      IO.puts "ALT BRANCH ..."
      {document.children, changeset}
    end
  end

  def levels_equal({child1, child2}) do
    child1.level == child2.level
  end

  def levels_changed(children1, children2) do
    pairs = List.zip [children1, children2]
    Enum.filter pairs, fn(pair) -> not levels_equal(pair) end
  end

  # DocManager.do_level_change {c,c}
  def do_level_change({old_child, new_child}) do
    id = new_child.doc_id
    level = new_child.level
    doc = DocManager.get_document! id
    IO.puts "*** Setting level of #{doc.title} to #{level}"
    Document.set_level(doc, level)
  end

  def update_levels(old_children, new_children) do
    IO.puts "length of old children = #{length(old_children)}"
    IO.puts "length of new children = #{length(new_children)}"
    if length(old_children) == length(new_children) do
      IO.puts "*** UPDATING LEVELS .."
      levels_changed(old_children, new_children)
      |> Enum.map(fn pair -> do_level_change(pair) end)
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

  def table_of_contents_separator do
    "++ Table of Contents\n"
  end

  def parse_string(input) do
    [a|b] = String.split(input, table_of_contents_separator())
    str = if b == [] do
      a
    else
      b |> hd
    end

    String.split(str, ["\n", "\r", "\r\n"])
      |> Enum.map(fn(line) -> String.trim(line) end) # trim line
      |> Enum.with_index(1)                          # map line to {line, line_number}
      |> Enum.map(fn(item) -> parse_line(item) end)
  end

  def parse_line(item) do
    {line, line_number} = item
    words = line |> String.split(" ")
      |> Enum.filter(fn(word) -> word != "" end)
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
    comment = if tail2 == [] do
      ""
    else
      tail2 |> hd |> String.trim
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

  def updated_text_from_children(content, children) do
    content = if String.ends_with? content, "\n" do content else content <> "\n" end
    content = if !(String.contains? content, table_of_contents_separator())  do
      content <> table_of_contents_separator() <> "\n"
    else
      content
    end
    top_content = String.split(content, table_of_contents_separator()) |> hd
    toc_text = toc_from_children(children)
    top_content <> table_of_contents_separator() <> toc_text
  end

  def update_text_from_children({children, changeset}, document, content) do
    if document.attributes["doc_type"] == "master" && String.contains? content, table_of_contents_separator() do
      Ecto.Changeset.put_change(changeset, :content, updated_text_from_children(content, children))
    else
      changeset
    end
  end

  def toc_from_children(children) do
    Enum.reduce(children, "", fn(child, acc) -> acc <> stringOfChild(child) end)
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

    level = 2

    new_child = %Child{doc_id: child_id, level: level,
      title: child_document.title, doc_identifier: child_document.identifier,
      comment: "comment"}

    Document.set_parent(Document.child_document(new_child), document.id)
    Document.set_level(child_document, level)

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
    updated_text = updated_text_from_children(document.content, children)
    [doc, updated_text]
  end

  def attach!(document, position, remaining_commands) do
    [doc, updated_text] = attach(document, position, remaining_commands)
    cs = Document.changeset(doc, %{content: updated_text})
    Repo.update!(cs)
  end

  def index_of_child_with_id(children, id) do
    Enum.find_index(children, fn(child) -> child.doc_id == id end) || 0
  end

  def insert_before(item, position, items) do
    Enum.take(items, position) ++ [item] ++ Enum.drop(items, position)
  end

  def insert_after(item, position, items) do
    Enum.take(items, position+1) ++ [item] ++ Enum.drop(items, position+1)
  end


  # Return list of ids of master document
  def id_list(master_document) do
    master_document.children |> Enum.map fn(child) -> child.doc_id end
  end

  # If the master document defines a texmacro document, prepend it
  # to the master document id list and return.  Otherwise, return
  # the master document id list
  def id_list_with_texmacros(master_document) do
    with {:ok, texmacro_id} <- Document.texmacro_file_id master_document
    do
      ids = [texmacro_id] ++ id_list(master_document)
    else
      err -> id_list(master_document)
    end
  end

end
