defmodule Koko.DocManager.Search do

  alias Koko.DocManager.Document
  alias Koko.DocManager.Query
  alias Koko.Repo


  def for_public do
    Ecto.Adapters.SQL.query!(Repo, Query.public).rows
    |> List.flatten
    |> Enum.map fn id -> Repo.get!(Document, id) end
  end


  def for_author(author_id) do
    Document
       |> Query.for_author(author_id)
       |> Repo.all
  end

end
