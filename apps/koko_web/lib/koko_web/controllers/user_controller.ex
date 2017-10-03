defmodule Koko.Web.UserController do
  use Koko.Web, :controller

  plug :scrub_params, "user" when action in [:create]

  alias Koko.User.Authentication
  alias Koko.User.Token
  alias Koko.User.User
  alias Koko.Document.DocManager
  alias Koko.Document.Search


  action_fallback Koko.Web.FallbackController

  def index(conn, _params) do
    users = Search.by_query_string(:user, conn.query_string, ["sort=user"])
    render(conn, "index.json", users: users)
  end

  defp home_page_params(user) do
    %{
      "title" => "#{String.capitalize(user.username)}'s Home Page",
      "content" => "This is your home page. Edit it to make it be like you want it",
      "rendered_content" => "This is your home page. Edit it to make it be like you want it",
      "attributes" => %{"public" => true},
      "tags" => ["home"]
    }
  end


  def create(conn, %{"user" => payload}) do
    username = payload["username"]
    email = payload["email"]
    errors = Authentication.user_available username, email
    case errors do
      [] -> create(:success, conn, payload)
      _ -> create(:error, conn, errors)
    end

  end

  def create(:success, conn, payload) do
    user_params = Koko.Utility.project2map(payload)
    with {:ok, %User{} = user} <- Authentication.create_user(user_params) do
      {:ok, token} = Token.get(user.id, user.username, 86400)
      user = Map.merge(user, %{token: token, blurb: ""})
      DocManager.create_document(home_page_params(user), user.id)
      DocManager.add_notes_for_user(user.id)
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show_with_token.json", user: user)
    end
  end

  def create(:error, conn, errors) do
    error_message = Enum.join(errors, "; ") <> "."
    conn |> render("error.json", error: error_message)
  end

  def show(conn, %{"id" => id}) do
    user = Authentication.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => payload}) do
    user_params = Koko.Utility.project2map(payload)
    user = Authentication.get_user!(id)
    with {:ok, %User{} = user} <- Authentication.minimal_update_user(user, user_params) do
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
