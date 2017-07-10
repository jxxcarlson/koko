
# alias Koko.DocManager.MasterDocument; MasterDocument.parse_line("This is   a test")
defmodule Koko.DocManager.MasterDocument do

  alias Koko.Repo
  alias Koko.DocManager.Document
  import Child

  # alias Koko.Repo; alias Koko.DocManager.Document
  # alias Koko.DocManager.MasterDocument; MasterDocument.parse_line({"== 1", 33})

  str = """
== 1 // First document
== 3 // Trajectories and uncertainty
// The next item is invalid
=== 555
"""

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
    Enum.reduce 1..level, "", fn(k, acc) -> "=" <> acc end
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

    lines = String.split(str, ["\n", "\r", "\r\n"])
      |> Enum.map(fn(line) -> String.trim(line) end)
      |> Enum.with_index(1)
      |> Enum.map(fn(item) -> parse_line(item) end)
  end

  defp parse_line(item) do
    {line, line_number} = item
    words = line |> String.split(" ")
      |> Enum.filter fn(word) -> word != "" end
    IO.inspect words
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
    IO.inspect([line_number, line])
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



end
