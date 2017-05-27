defmodule Koko.Web.UserController do
  use Koko.Web, :controller

  alias Koko.Authentication
  alias Koko.Authentication.User
  alias Koko.Authentication.Session

  action_fallback Koko.Web.FallbackController

  def index(conn, _params) do
    users = Authentication.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Authentication.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  ##############################


  # plug :scrub_params, "user" when action in [:create]


    def create2(conn, %{"user" => payload}) do

      # user_params = TextApi.Utility.project2map(payload)
      changeset = User.registration_changeset(%User{}, payload)

      case Repo.insert(changeset) do
        {:ok, user} ->
          session_changeset = Session.create_changeset(%Session{}, %{user_id: user.id})
          {:ok, session} = Repo.insert(session_changeset)
  #        {:ok, session} = TextApi.Session.create_session(user)
          conn
          |> put_status(:created)
         # |> render("show.json", user: user)
          |> render("show.json", session: session)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(ChangesetView, "error.json", changeset: changeset)
      end
    end

  ##############################

  def show(conn, %{"id" => id}) do
    user = Authentication.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Authentication.get_user!(id)

    with {:ok, %User{} = user} <- Authentication.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Authentication.get_user!(id)
    with {:ok, %User{}} <- Authentication.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
