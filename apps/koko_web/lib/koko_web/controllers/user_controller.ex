defmodule Koko.Web.UserController do
  use Koko.Web, :controller

  plug :scrub_params, "user" when action in [:create]

  alias Koko.User.Authentication
  alias Koko.User.Token
  alias Koko.User.User
  alias Koko.Repo
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

  def saveuserstate(conn, %{"id" => id, "current_document_id" => current_document_id, "id_list" => id_list}) do
    user = Authentication.get_user!(id)
    params = %{"current_document_id" => current_document_id, "document_ids" => id_list}
    with {:ok, %User{} = user} <- Authentication.update_user_state(user, params) do
      render(conn, "show.json", user: user)
    end
  end

  def getuserstate(conn, %{"id" => id}) do
    IO.puts "x1x1: in getuserstate, id = #{id}"
    user = Authentication.get_user!(id)
    IO.inspect user, label: "x1x1: in getuserstate"
    render(conn, "userstate.json", user: user)
  end



  def delete(conn, %{"id" => id}) do
    IO.puts "TOKEN"
    token = Token.token_from_header(conn)
    IO.puts token
    IO.inspect Token.payload(token)
    with  {:ok, admin_id} <- Token.user_id_from_header(conn),
      true <- admin_id == 1
    do
      IO.puts "Admin id = #{admin_id}"
      user = Repo.get(User, id)
      IO.puts "User to delete = #{user.username}"
      Repo.delete(user)
      render(conn, "reply.json", reply: "deleted user #{id} (#{user.username})")
    else
      err -> render(conn, "reply.json", reply: "Could not delete user #{id}")

    end
  end
end
