defmodule Koko.Authentication do
  @moduledoc """
  The boundary for the Authentication system.
  """

  import Ecto.Query, warn: false
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

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




  alias Koko.Authentication.Session

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id)

  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_session(params \\ %{}) do
       %{"email"=> email, "password" => password} = params
       IO.puts "in auth, create_session:"
       IO.puts "email: #{email}"
       IO.puts "password: #{password}"
       IO.puts "-------------------------"
      # user_id = get_value_of_key(:user_id, params) #params[:user_id] || params["user_id"]
      # username = get_value_of_key(:username, params) # params[:username] || params["username"]
    with  {:ok, user} <- get_user(params["email"]),
          {:ok, password} <- checkpw(params["password"], user.password_hash),
          {:ok, token} <- Koko.Authentication.Token.get(user.id, user.username)
    do
      IO.puts "token: #{token}"
      %Session{}
        |> Session.changeset(%{username: user.username, user_id: user.id, token: token})
        |> Repo.insert()
      else
        err -> {:error, "Could not create session"}
    end
  end

  defp get_user(nil), do: {:error, "email is required"}
  defp get_user(email), do: Repo.get_by(User, email: email)

  #
  # def login(conn, user) do
  #   conn
  #   |> assign(:current_user, user)
  #   |> put_session(:user_id, user.id)
  #   |> configure_session(renew: true)
  # end


  @doc """
  Deletes a Session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end


end
