defmodule Koko.Web.UserController do
  use Koko.Web, :controller

  plug :scrub_params, "user" when action in [:create]

  alias Koko.Authentication
  alias Koko.Authentication.User
  alias Koko.DocManager

  action_fallback Koko.Web.FallbackController

  def index(conn, _params) do
    users = Authentication.list_users()
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
    user_params = Koko.Utility.project2map(payload)
    with {:ok, %User{} = user} <- Authentication.create_user(user_params) do
      {:ok, token} = Koko.Authentication.Token.get(user.id, user.username, 86400)
      user = Map.merge(user, %{token: token})
      DocManager.create_document(home_page_params(user), user.id)
      IO.inspect user
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show_with_token.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Authentication.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => payload}) do
    user_params = Koko.Utility.project2map(payload)
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
