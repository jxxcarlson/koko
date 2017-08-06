defmodule Koko.Authentication.UserQuery do

  import Ecto.Query
  alias Koko.Authentication.User
  alias Koko.Repo

  ## QUERIES

  def by_username(query, username) do
    from u in query,
      where: u.username == ^username
  end

  def by_email(query, email) do
    from u in query,
      where: u.email == ^email
  end

  ## GET USER

  def get_by_email(email) do
    User |> by_email(email) |> Repo.one
  end

  def get_by_username(username) do
    User |> by_username(username) |> Repo.one
  end

end
