defmodule Koko.DocManager.Search do

  alias Koko.DocManager.Document
  alias Koko.DocManager.Query
  alias Koko.Repo
  alias Koko.Utility
  alias Koko.Authentication.User

  def by_command_list(command_list, :document) do
    IO.puts "ENTER DOCUMENT COMMAND_LIST"
    command_list
    |> Enum.reduce(Document, fn [cmd, arg], query -> Query.by(query, cmd, arg) end)
    |> Repo.all
  end

  def by_command_list(command_list, :user) do
    IO.puts "ENTER USER COMMAND_LIST"
    command_list
    |> Enum.reduce(User, fn [cmd, arg], query -> Query.by(query, cmd, arg) end)
    |> Repo.all
  end

  ################
    # https://stackoverflow.com/questions/27751216/how-to-use-raw-sql-with-ecto-repo
    # https://hackernoon.com/how-to-query-jsonb-beginner-sheet-cheat-4da3aa5082a3

   def random_public do
 #     query1 = """
 # SELECT * FROM documents WHERE attributes @> '{"public": true}' OFFSET floor(random()*176) LIMIT 20;
 # """
     query = "SELECT * FROM documents OFFSET floor(random()*176) LIMIT 30;"
     res = Ecto.Adapters.SQL.query!(Repo, query, [])
     cols = Enum.map res.columns, &(String.to_atom(&1))
     Enum.map(res.rows, fn(row) -> struct(Document, Enum.zip(cols, row)) end)
     |> Enum.filter(fn(item) -> item.attributes["public"] end)
     |> Enum.take(10)
   end

   def random do
     query = "SELECT * FROM documents OFFSET floor(random()*176) LIMIT 20;"
     res = Ecto.Adapters.SQL.query!(Repo, query, [])
     cols = Enum.map res.columns, &(String.to_atom(&1))
     Enum.map(res.rows, fn(row) -> struct(Document, Enum.zip(cols, row)) end)
     |> Enum.take(10)
   end


  defp parse_query_string(str) do
    str
    |> String.split("&")
    |> (Enum.map fn(item) -> String.split(item, "=") end)
  end

  def prepend_options(query_string, options) do
    if query_string == "" do
      Enum.join(options, "&")
    else
      Enum.join(options ++ [query_string] , "&")
    end
  end

  def by_query_string(domain, query_string, options) do
    IO.inspect domain, label: "by_query_string, domain"
    query_string
    |> prepend_options(options)
    |> Utility.inspect_pipe("QS:")
    |> parse_query_string
    |> Utility.inspect_pipe("COMMANDS:")
    |> by_command_list(domain)
    |> Utility.inspect_pipe("FINAL QUERY:")
    # |> Utility.inspect_pipe("QUERY:")
  end

  def by_query_string_for_user(query_string, user_id) do
    IO.puts "QS: #{query_string}"
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

end
