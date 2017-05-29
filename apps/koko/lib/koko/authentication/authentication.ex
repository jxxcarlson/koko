defmodule Koko.Authentication do
  @moduledoc """
  The boundary for the Authentication system.
  """

  import Ecto.Query, warn: false
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Koko.Repo
  alias Koko.Authentication.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end



#################################

  @doc """
  Authentication.get_token(%{"email" => "h12gg@foo.io", "password" => "yada+yada"}) ==
  {:ok, "aaa.bbb.ccc", "joe23"} if the request is valid.  Here "aaa.bbb.ccc" is the
  authentication token and "joe23" is the username.

  If the request is invalid, then {:error, "Incorrect password or email"} is returned.
  """
  def get_token(params \\ %{}) do
    with  {:ok, user} <- get_user(params["email"]),
          {:ok, _} <- checkpw2(params["password"], user.password_hash),
          {:ok, token} <- Koko.Authentication.Token.get(user.id, user.username)
    do
      {:ok, token, user.username}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp get_user(nil), do: {:error, "email is required"}

  defp get_user(email) do
    user =  Repo.get_by(User, email: email)
    case user do
     nil -> {:error, "User not found"}
     _ -> {:ok, user}
    end
  end

  defp checkpw2(password, password_hash) do
    if  checkpw(password, password_hash) == true do
      {:ok, true}
    else
      {:error, "Incorrect password or email"}
    end
  end

  #   def login_by_username_and_pass(conn, username, given_pass, opts) do
  #     repo = Keyword.fetch!(opts, :repo)
  #     user = Repo.get_by(User, username: username)
  #     cond do
  #       user && checkpw(given_pass, user.password_hash) ->
  #        {:ok, login(conn, user)}
  #       user ->
  #         {:error, :unauthorized, conn}
  #       true ->
  #         dummy_checkpw()
  #         {:error, :not_found, conn}
  #     end
  #   end
  #
  #   def logout(conn) do
  #     configure_session(conn, drop: true)
  #   end

end
