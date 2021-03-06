defmodule Koko.User.Query do

  import Ecto.Query
  alias Koko.User.User
  alias Koko.Repo

  ## QUERIES

  def is_public(query) do
    from u in query,
      where: u.public == ^true
  end

  def by_username(query, username) do
    from u in query,
      where: u.username == ^username
  end

  def by_id(query, id) do
    from u in query,
      where: u.id == ^id
  end

  def by_email(query, email) do
    from u in query,
      where: u.email == ^email
  end

  def sort_by_username(query) do
      from u in query,
        order_by: [asc: u.username]
  end

  ## GET USER

  def get_by_email(email) do
    User |> by_email(email) |> Repo.one
  end

  def get_by_username(username) do
    User |> by_username(username) |> Repo.one
  end

  def get(id) do
    User |> by_id(id) |> Repo.one
  end


end
