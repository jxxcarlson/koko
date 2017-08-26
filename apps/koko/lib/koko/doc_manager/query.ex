defmodule Koko.DocManager.Query do

  import Ecto.Query
  alias Koko.Authentication.User
  alias Koko.Repo
  alias Koko.DocManager.Document




  @doc """
  Return a list of 2-lists, e.g., the input "foo=1&bar=2"
  yields the output [[foo, 1], [bar, 2]]

  Generic example for using these queries:

    iex> Document |> Query.has_title("math") |> Query.has_author(2) |> Repo.all

alias Koko.DocManager.Query; alias Koko.DocManager.Document; alias Koko.Repo; alias Koko.DocManager

    Document |> Query.is_public |> Repo.all

  """


 def by(query, cmd, arg) do
    case {cmd, arg} do
      {"user_or_public", _} ->
        for_user_or_public(query, arg)
      {"author",_} ->
        has_author(query, arg)
      {"authorname",_} ->
          has_author_name(query, arg)
      {"title", _} ->
        has_title(query, arg)
      {"sort", "created"} ->
        sort_by_inserted_at(query)
      {"sort", "updated"} ->
          sort_by_updated_at(query)
      {"sort", "viewed"} ->
          sort_by_viewed_at(query)
      {"sort", "title"} ->
          sort_by_title(query)
      {"text",_} ->
        has_text(query, arg)
      {"key", _} ->
        has_tag(query, arg)
      {"public", "yes"}  ->
        is_public(query)
      {"public", "no"}  ->
        is_not_public(query)
      {"public_user", "yes"} ->
        is_public_user(query)
      {"is_user", _} ->
        is_user(query, arg)
      {"sort", "user"} ->
          sort_by_user(query)
      {"id", _} ->
        has_id(query, arg)
      {"ident", _} ->
          has_identifier_suffix(query, arg)
      {"limit", _} ->
          has_limit(query, arg)
        has_title(query, arg)
    end
 end

 def for_user_or_public(query, author_id)  do
   from d in query,
     where:  (d.author_id == ^author_id) or (fragment("attributes @> '{\"public\": true}'"))
 end

  def has_author(query, author_id) do
    from d in query,
      where: d.author_id == ^author_id
  end

  ###################### USER QUERIES ##########################

  def is_user(query, term) do
    from u in query,
      where: ilike(u.username, ^"%#{term}%") or ilike(u.blurb, ^"%#{term}%")
  end

  def sort_by_user(query) do
        from u in query,
        order_by: [asc: u.username]
  end

  def is_public_user(query) do
    from u in query,
      where: u.public == ^true
  end

  #############################################################

  def has_author_name(query, author_name) do
    author = User |> is_user(author_name) |> Repo.one
    if author != nil do
      from d in query,
        where: d.author_id == ^author.id
     else
       query
     end
  end

  def sort_by_title(query) do
        from d in query,
        order_by: [asc: d.title]
  end

  def sort_by_inserted_at(query) do
        from d in query,
        order_by: [desc: d.inserted_at]
  end

  def sort_by_updated_at(query) do
        from d in query,
        order_by: [desc: d.updated_at]
  end

  def sort_by_viewed_at(query) do
        from d in query,
        order_by: [desc: d.viewed_at]
  end

  def has_title(query, term) do
       from d in query,
         where: ilike(d.title, ^"%#{term}%")
  end

  def has_identifier_suffix(query, term) do
    from d in query,
      where: ilike(d.identifier, ^"%#{term}%")
  end

  def has_id(query, term) do
    from d in query,
      where: d.id == ^term
  end

  def has_text(query, term) do
       from d in query,
         where: ilike(d.content, ^"%#{term}%")
  end

  def is_public(query)do
    # fragment("? @&gt; '{?: ?}'", unquote(field), unquote(key), unquote(value))
    from d in query,
      where: fragment("attributes @> '{\"public\": true}'")
  end

  def is_not_public(query)do
    # fragment("? @&gt; '{?: ?}'", unquote(field), unquote(key), unquote(value))
    from d in query,
      where: fragment("attributes @> '{\"public\": false}'")
  end


  def has_tag(query, tag) do
    from d in query,
      where: ^tag in d.tags
      # fragment("? @> '{?}'", d.tags, ^tag)
  end

  def has_limit(query, limit) do
    from d in query,
      limit: ^limit
 end


 



  # https://hackernoon.com/how-to-query-jsonb-beginner-sheet-cheat-4da3aa5082a3
  # https://elixirnation.io/references/ecto-query-examples
  # https://elixirforum.com/t/how-do-i-use-the-postgres-jsonb-postgrex-json-extension/3214/2
  # https://hexdocs.pm/ecto/Ecto.Query.API.html#fragment/1

  # d = Repo.get(Document, 1)
  # cs = Document.changeset(d, %{attributes: %{public: false}})
  # Repo.update(cs)

  # BUILD QUERIES (macros): https://github.com/belaustegui/trans/blob/master/lib/trans/query_builder.ex#L90-L100


end
