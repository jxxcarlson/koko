defmodule Koko.User.Authentication do
  @moduledoc """
  The boundary for the Authentication system. It manages
  user registration and authentication: a registered user
  can present email and password to receive a JWTtoken that
  grants access to the system.  A user can then create documents
  (of which he will be the author/owner), as well as list,read, edit,
  and delete them.  User actions run through /api/users and document
  actions through /api/documents.  Documents which carry the attribute
  public: true may be listed and read through the /api/public/documents
  route.

  NOTE:

  """

  import Ecto.Query, warn: false
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Koko.Repo
  alias Koko.User.User
  alias Koko.User.Query

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(_query_string) do
    User |> Query.sort_by_username |> Repo.all
  end

  ##  List users whose home page is public
  ##
  def list_public_users do
    User |> Query.is_public |>Query.sort_by_username |> Repo.all
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


  def user_available(username, email) do
    username = username || ""
    email = email || "--"
    errors = []
    cond do
      String.length(username) < 4 ->
          errors ++ ["Username must have at least four characters"]
      not (String.contains? email, "@") ->
          errors ++ ["Email is invalid"]
      Query.get_by_email(email) != nil ->
          errors ++ ["That email is taken"]
      Query.get_by_username(username) != nil ->
          errors ++ ["That username is taken"]
      true ->
          IO.inspect errors
    end
  end

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

  def minimal_update_user(%User{} = user, attrs) do
    user
    |> User.minimal_changeset(attrs)
    |> Repo.update()
  end

  def update_user_state(%User{} = user, attrs) do
    user
    |> User.user_state_changeset(attrs)
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
    IO.puts "get_token"
    with  {:ok, user} <- get_user(params["email"]),
          {:ok, _} <- checkpw2(params["password"], user.password_hash),
          {:ok, token} <- Koko.User.Token.get(user.id, user.username)
    do
      {:ok, token, user.username}
    else
      {:error, _} -> {:error, "Incorrect username (email) or password"}
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



end
