defmodule Koko.DocManager.Search do

  alias Koko.DocManager.Document
  alias Koko.DocManager.Query
  alias Koko.Repo
  alias Koko.DocManager.QP

  require Koko.DocManager.QP


  def by_command_list(command_list) do
    n = length command_list
    case n do
      1 ->
        QP.query1(command_list)
      2 ->
        QP.query2(command_list)
      3 ->
        QP.query3(command_list)
      4 ->
        QP.query4(command_list)
      _ ->
        QP.query5(command_list)
    end

  end

  def parse_query_string(str) do
    str
    |> String.split("&")
    |> (Enum.map fn(item) -> String.split(item, "=") end)
  end
  #
  # def by_query_string(query_string) do
  #   qs = query_string
  #   |> parse_query_string
  #   IO.inspect qs
  #   qs
  #   |> by_command_list
  # end


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
