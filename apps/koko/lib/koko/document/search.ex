defmodule Koko.Document.Search do

  alias Koko.Document.Document
  alias Koko.Document.Query
  alias Koko.Repo
  alias Koko.Utility
  alias Koko.User.User

  def search_limit do
    20
  end

  @doc"""
  # Sort command list by priority

    iex> cl = [["key", "foo"], ["title", "elm"]]
    [["key", "foo"], ["title", "elm"]]
    iex> Koko.Document.Search.sort_commands cl
    [["title", "elm"], ["key", "foo"]]

  """
  def sort_commands(command_list) do
    command_list
    |> Enum.sort fn(x, y) -> Query.is_greater(hd(x), hd(y)) end
  end



  """
  # Example

    > cl = [["author", "1"], ["title", "elm"], ["sort", "title"]]
    > Koko.Document.Search.by_command_list(cl, :document) |> length
    6

    > cl = [["author", "1"], ["title", "elmmm"], ["sort", "title"]]
    > Koko.Document.Search.by_command_list(cl, :document) |> length
    2

    Note: not a pure function, so can't do a doctest.
  """
  def by_command_list(command_list, :document) do
    IO.puts "ENTER DOCUMENT COMMAND_LIST"
    IO.inspect command_list, label: "Command list"
    command_list
    |> sort_commands
    |> Utility.inspect_pipe("SORTED COMMANDS")
    |> Enum.reduce(Document, fn [cmd, arg], query -> Query.by(query, cmd, arg) end)
    |> Repo.all
  end

  def by_command_list(command_list, :user) do
    IO.puts "ENTER USER COMMAND_LIST"
    IO.inspect command_list, label: "Command list"
    command_list
    |> sort_commands
    > Utility.inspect_pipe("SORTED COMMANDS")
    |> Enum.reduce(User, fn [cmd, arg], query -> Query.by(query, cmd, arg) end)
    |> Repo.all
  end

  ################
    # https://stackoverflow.com/questions/27751216/how-to-use-raw-sql-with-ecto-repo
    # https://hackernoon.com/how-to-query-jsonb-beginner-sheet-cheat-4da3aa5082a3

   def random_public query_string do
 #     query1 = """
 # SELECT * FROM documents WHERE attributes @> '{"public": true}' OFFSET floor(random()*176) LIMIT 20;
 # """
     rows = rows_in_table("documents")
     query = "SELECT * FROM documents OFFSET floor(random()*#{rows}) LIMIT 40;"
     IO.puts "SQL query = #{query}"
     res = Ecto.Adapters.SQL.query!(Repo, query, [])
     cols = Enum.map res.columns, &(String.to_atom(&1))
     Enum.map(res.rows, fn(row) -> struct(Document, Enum.zip(cols, row)) end)
     |> Enum.filter(fn(item) -> item.attributes["public"] end)
     |> Enum.take(10)
     |> Enum.sort(fn(x,y) -> x.title < y.title end)
   end

   """
   Use raw SQL query to get a count of rows in any table, e.g.
     > Search.rows_in_table("documents")
     233
   """
   def rows_in_table(table) do
     countQuery = "SELECT count (*) FROM #{table};"
     countResponse = Ecto.Adapters.SQL.query!(Repo, countQuery, [])
     countResponse.rows |> hd |> hd
   end

   # REF: https://stackoverflow.com/questions/31220622/get-random-elements-from-a-list
   def random_user query_string do
     user_id_ = parse_query_string(query_string)
       |> Enum.filter(fn(item) -> hd(item) == "random_user" end)
       |> hd
       |> Enum.at(1)
     query = "SELECT * FROM documents WHERE author_id=#{user_id_}"
     res = Ecto.Adapters.SQL.query!(Repo, query, [])
     cols = Enum.map res.columns, &(String.to_atom(&1))
     Enum.map(res.rows, fn(row) -> struct(Document, Enum.zip(cols, row)) end)
     |> Enum.take_random(10)
     |> Enum.sort(fn(x,y) -> x.title < y.title end)
   end

   """
   # Example 1: return n <= 10 random records for the user with id = 1

   > Search.random("user_id=1") |> length
   > 10

   Called by: DocumentController.index
   """
   def random(query_string) do
     rows = rows_in_table("documents")
     user_id = get_query_value("user_id", query_string)
     query = "SELECT * FROM documents OFFSET floor(random()*#{rows}) LIMIT 40;"
     res = Ecto.Adapters.SQL.query!(Repo, query, [])
     cols = Enum.map res.columns, &(String.to_atom(&1))  ## XXX: Danger here!
     Enum.map(res.rows, fn(row) -> struct(Document, Enum.zip(cols, row)) end)
     |> Enum.filter(fn(item) -> item.attributes["public"] or item.author_id == user_id end)
     |> Enum.take(10)
     |> Enum.sort(fn(x,y) -> x.title < y.title end)
   end

  @doc"""
    # Example: parse query string into command list

    iex> Koko.Document.Search.parse_query_string("title=vis&title=lit&sort=viewed")
    [["title", "vis"], ["title", "lit"], ["sort", "viewed"]]

  """
  def parse_query_string(str) do
    str
    |> String.split("&")
    |> (Enum.map fn(item) -> String.split(item, "=") end)
    |> (Enum.filter fn(item) -> length(item) == 2 end)
  end

  """
  # Examples:
    iex> Search.get_query_value("foo", "foo=1&bar=2")
    "1"

    iex> Search.get_query_value("fooy", "foo=1&bar=2")
    ""
  """
  def get_query_value(key, query) do
    if String.contains? query, key do
      parse_query_string(query)
        |> Enum.filter(fn(item) -> hd(item) == key end)
        |> hd
        |> Enum.at(1)
    else
      ""
    end
  end

  """
  prepend_options: a convenience method to prepend_options
  to a query string.  The options are given as a list of the
  form [key1=value1, key2=value2, ...]
  """
  defp prepend_options(query_string, options) do
    if query_string == "" do
      Enum.join(options, "&")
    else
      Enum.join(options ++ [query_string] , "&")
    end
  end

  """
  Example: Search for documents by query string

  > Koko.Document.Document.by_query_string(
      :document,
      "title=vis&title=lit&sort=viewed",
      ["author=1", "limit=20"] ) |> length
  1
  """
  def by_query_string(domain, query_string, options) do
    query_string
    |> prepend_options(options)
    #|> Utility.inspect_pipe("QS:")
    |> parse_query_string
    #|> Utility.inspect_pipe("COMMANDS:")
    |> by_command_list(domain)
    #|> Utility.inspect_pipe("FINAL QUERY:")
  end


  """
  by_query_string_for_user(query_string, user_id)
  ensures that "author=USER_ID" is prepended to
  the query string, ensures that "sort=title"
  is postpended, and then dispatches the search
  to "by_query_string"
  """
  def by_query_string_for_user(query_string, user_id) do
    IO.puts "QS (for USER)): #{query_string}"
    query_string = query_string || ""
    # prepend author query
    query_string = if query_string == "" do
       "author=#{user_id}"
    else
       "author=#{user_id}&#{query_string}"
    end
    # query_string = "#{query_string}&limit=5"
    # postpend sort by title
    query_string = if String.contains?(query_string, "sort=title") do
      query_string
    else
      "#{query_string}&sort=title"
    end
    by_query_string(:document, query_string, [])
  end

  defp remove_command(command, query_string) do
    query_string
    |> String.split("&")
    |> Enum.filter(fn(c) -> c != command end)
    |> Enum.join("&")
  end

  defp prepend_command(command, query_string) do
    if query_string == "" do
      command
    else
      "#{command}&#{query_string}"
    end
  end

  def get_documents_for_user(user_id, query_string, opts) do
    cond do
      query_string == "userdocs=all" ->
        {qs, opts2} = {"", ["author=#{user_id}", "limit=#{search_limit()}"] ++ opts}
      String.contains? query_string, "docs=any" ->
        qs = remove_command("docs=any", query_string)
        {qs, opts2} = { qs, [] ++ ["user_or_public=#{user_id}", "limit=#{search_limit()}"]}
      true ->
        {qs, opts2} = {query_string, ["author=#{user_id}", "limit=#{search_limit()}"] ++ opts}
    end
    by_query_string(:document, qs, opts2)
  end


end
