defmodule Koko.DocManager.Query do

  import Ecto.Query

  def for_author(query, author_id) do
    from d in query,
      where: d.author_id == ^author_id
  end

  # https://hackernoon.com/how-to-query-jsonb-beginner-sheet-cheat-4da3aa5082a3
  # https://elixirnation.io/references/ecto-query-examples
  # https://elixirforum.com/t/how-do-i-use-the-postgres-jsonb-postgrex-json-extension/3214/2
  # https://github.com/belaustegui/trans/blob/master/lib/trans/query_builder.ex#L90-L100
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
