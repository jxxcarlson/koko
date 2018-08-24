defmodule Koko.Document.Query do

  import Ecto.Query
  alias Koko.User.User
  alias Koko.Repo
  # alias Koko.Document.Document




  @doc """
  Return a list of 2-lists, e.g., the input "foo=1&bar=2"
  yields the output [[foo, 1], [bar, 2]]

  Generic example for using these queries:

  #  iex> Document |> Query.has_title("math") |> Query.has_author(2) |> Repo.all

alias Koko.DocManager.Query; alias Koko.DocManager.Document; alias Koko.Repo; alias Koko.DocManager

    Document |> Query.is_public |> Repo.all

  """


 def priority_table do
   %{
     "id" => 7,
     "ident" => 7,
     "is_user" => 7,
     "title" => 6,
     "key" => 5,
     "author" => 4,
     "authorname" => 4,
     "public_user" => 4,
     "days_before" => 4,
     "created" => 4,
     "updated" => 4,
     "viewed" => 4,
     "text" => 3,
     "public" => 2,
     "is_master" => 3,
     "sort" => 1,
     "limit"  => 0,
     "user_id" => 7,
     "name" => 7
   }
 end

 @doc"""
 # Query.priority returns the priority of a search command

    iex> Koko.Document.Query.priority("title")
    6

    iex> Koko.Document.Query.priority("foo")
    -1
 """
 def priority(command) do
   priority_table[command] || -1
 end

 @doc"""
 # Compare priorities of search commands

    iex> Koko.Document.Query.is_greater "title", "sort"
    true
 """
 def is_greater(command1, command2) do
   priority(command1) > priority(command2)
 end


 def by(query, cmd, arg) do
    case {cmd, arg} do
      {"user_or_public", _} ->
        for_user_or_public(query, arg)
      {"author",_} ->
        has_author(query, arg)
      {"user_id",_} ->
        has_user_id(query, arg)
      {"authorname",_} ->
          has_author_name(query, arg)
      {"title", _} ->
        has_title(query, arg)
      {"name", _} ->
        has_name(query, arg)
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
      {"days_before", days} ->
         days_before(query, days)
      {"created", days} ->
        created(query, days)
      {"updated", days} ->
        updated(query, days)
      {"viewed", days} ->
        viewed(query, days)
      {"limit", _} ->
          has_limit(query, arg)
      {"is_master","yes"} ->
         is_master(query)
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

  def has_user_id(query, user_id) do
    from d in query,
      where: d.user_id == ^user_id
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
      from d in query,
      where: d.title == ^"xy2ek!!fo9r3" # stupid way to abort search
     end
  end

  def days_before(query, days_ago) do
     # date = ~D[2018-04-30]
     today = Date.utc_today
     {k, _} = days_ago |> Integer.parse
     start_date = Date.add(today,-k)
     from d in query, where: fragment("?::date", d.inserted_at) >= ^start_date
  end

  def days_before(query, days_ago) do
    # date = ~D[2018-04-30]
    today = Date.utc_today
    {k, _} = days_ago |> Integer.parse
    start_date = Date.add(today,-k)
    from d in query, where: fragment("?::date", d.inserted_at) >= ^start_date
 end

 def created(query, created) do
  # date = ~D[2018-04-30]
  today = Date.utc_today
  {k, _} = created |> Integer.parse
  start_date = Date.add(today,-k)
  from d in query, where: fragment("?::date", d.inserted_at) >= ^start_date
end

def updated(query, updated) do
  # date = ~D[2018-04-30]
  today = Date.utc_today
  {k, _} = updated |> Integer.parse
  start_date = Date.add(today,-k)
  from d in query, where: fragment("?::date", d.updated_at) >= ^start_date
end

def viewed(query, viewed) do
  # date = ~D[2018-04-30]
  today = Date.utc_today
  {k, _} = viewed |> Integer.parse
  start_date = Date.add(today,-k)
  from d in query, where: fragment("?::date", d.viewed_at) >= ^start_date
end

  # Search.by_query_string(:document,"has_children=yes", []) |> length
  def is_master(query) do
    from d in query,
      where: fragment("attributes @> '{\"doc_type\": \"master\"}'")
    query
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

  def has_name(query, term) do
    from d in query,
      where: ilike(d.name, ^"%#{term}%")
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
    # from d in query,
    #   limit: ^limit
    query
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
