defmodule Koko.DocManager.Query do

  import Ecto.Query

  @doc """
  Return a list of 2-lists, e.g., the input "foo=1&bar=2"
  yields the output [[foo, 1], [bar, 2]]
  """


 def by(query, cmd, arg) do
    case {cmd, arg} do
      {"author",_} ->
        has_author(query, arg)
      {"title", _} ->
        has_title(query, arg)
      {"sort", "date"} ->
        sort_by_inserted_at(query)
      {"sort", "title"} ->
          sort_by_title(query)
      {"text",_} ->
        has_text(query, arg)
      _ ->
        has_title(query, arg)
    end
 end

  def has_author(query, author_id) do
    from d in query,
      where: d.author_id == ^author_id
  end

  def sort_by_title(query) do
        from d in query,
        order_by: [asc: d.title]
  end

  def sort_by_inserted_at(query) do
        from d in query,
        order_by: [desc: d.inserted_at]
  end

  def has_title(query, term) do
       from d in query,
         where: ilike(d.title, ^"%#{term}%")
  end

  def has_text(query, term) do
       from d in query,
         where: ilike(d.content, ^"%#{term}%")
  end


  # https://hackernoon.com/how-to-query-jsonb-beginner-sheet-cheat-4da3aa5082a3
  # https://elixirnation.io/references/ecto-query-examples
  # https://elixirforum.com/t/how-do-i-use-the-postgres-jsonb-postgrex-json-extension/3214/2
  # BUID QUERIES (macros): https://github.com/belaustegui/trans/blob/master/lib/trans/query_builder.ex#L90-L100
  # https://hexdocs.pm/ecto/Ecto.Query.API.html#fragment/1

  # d = Repo.get(Document, 1)
  # cs = Document.changeset(d, %{attributes: %{public: false}})
  # Repo.update(cs)

  def public do
"""
    SELECT id FROM documents WHERE attributes @> '{"public": true}';
  """
end


end
