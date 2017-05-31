defmodule Koko.DocManager.Search do

  alias Koko.DocManager.Document
  alias Koko.DocManager.Query
  alias Koko.Repo
  alias Koko.DocManager.QP


  def by_command_list(command_list) do
    command_list
    |> Enum.reduce(Document, fn [cmd, arg], query -> Query.by(query, cmd, arg) end)
    |> Repo.all
  end

  def parse_query_string(str) do
    str
    |> String.split("&")
    |> (Enum.map fn(item) -> String.split(item, "=") end)
  end

  def by_query_string(query_string) do
    query_string
    |> parse_query_string
    |> by_command_list
  end

  def by_query_string_for_user(query_string, user_id) do
    if query_string == "" || query_string == nil, do: query_string = "sort=title"
    if !String.contains?(query_string, "sort=title"), do: query_string = "#{query_string}&sort=title"
    by_query_string("author=#{user_id}&#{query_string}")
  end


  def for_public do
    Ecto.Adapters.SQL.query!(Repo, Query.public).rows
    |> List.flatten
    |> (Enum.map fn(id) -> Repo.get!(Document, id) end)
  end



  def for_user_with_query_string(user_id, query_string) do

  end

  def by_title_for_user(term, user_id) do
    Document
       |> Query.for_author(user_id)
       |> Query.select_by_title(term)
       |> Query.sort_by_title
       |> Repo.all
  end

  def for_author(author_id) do
    Document
       |> Query.for_author(author_id)
       |> Repo.all
  end

end
