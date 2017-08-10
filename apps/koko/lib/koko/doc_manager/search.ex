defmodule Koko.DocManager.Search do

  alias Koko.DocManager.Document
  alias Koko.DocManager.Query
  alias Koko.Repo
  alias Koko.Utility

  def by_command_list(command_list) do
    IO.puts "ENTER COMMAND_LIST"
    command_list
    |> Enum.reduce(Document, fn [cmd, arg], query -> Query.by(query, cmd, arg) end)
    |> Repo.all
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

  def by_query_string(query_string, options) do
    query_string
    |> prepend_options(options)
    |> Utility.inspect_pipe("QS:")
    |> parse_query_string
    |> Utility.inspect_pipe("COMMANDS:")
    |> by_command_list
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
    by_query_string(query_string, [])
  end




end
