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
    query_string = if query_string == "" || query_string == nil do
      "sort=title"
    else
      query_string
    end
    query_string = if !String.contains?(query_string, "sort=title"), do: "#{query_string}&sort=title"
    by_query_string("author=#{user_id}&#{query_string}")
  end

  def for_public do
    Ecto.Adapters.SQL.query!(Repo, Query.public).rows
    |> List.flatten
    |> (Enum.map fn(id) -> Repo.get!(Document, id) end)
  end


end
