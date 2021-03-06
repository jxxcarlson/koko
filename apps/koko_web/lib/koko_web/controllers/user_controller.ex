defmodule Koko.Web.UserController do
  use Koko.Web, :controller

  plug :scrub_params, "user" when action in [:create]

  plug :put_layout, false

  alias Koko.User.Authentication
  alias Koko.User.Token
  alias Koko.User.User
  alias Koko.Repo
  alias Koko.Document.DocManager
  alias Koko.Document.Search
  alias Koko.Email


  action_fallback Koko.Web.FallbackController

  def index(conn, _params) do
    users = Search.by_query_string(:user, conn.query_string, ["sort=user"])
    render(conn, "index.json", users: users)
  end

  def home_page_params(user) do
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

  def request_header_map(conn) do
    Enum.into conn.req_headers, %{}
  end

  def api_version_from_headers(conn) do 
    request_header_map(conn)["apiversion"] || "V1"
  end

  def create(:success, conn, payload) do
    IO.puts "CREATE USER"
    api_version = api_version_from_headers(conn)
    user_params = Koko.Utility.project2map(payload)
    IO.inspect api_version, label: "api_version"
    IO.inspect user_params, label: "user_params"
    with {:ok, %User{} = user} <- Authentication.create_user(user_params) do
      {:ok, token} = Token.get(user.id, user.username, 86400)
      user = Map.merge(user, %{token: token, blurb: "", active: true, verified: false})
      DocManager.create_document(home_page_params(user), user.id)
      DocManager.add_notes_for_user(user.id)
      send_confirmation_email(conn, user)
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render_for_create_user(api_version, user)
    end
  end

  def verify(conn, params) do
    token = params["token"]
    with true <- Token.authenticated token do
      {:ok, payload} = Token.payload token
      username = payload["username"]
      user_id = payload["user_id"]
      user = Repo.get(User, user_id)
      cs = User.safe_changeset(user, %{verified: true})
      Repo.update(cs)
      Email.email_plain %{
        "recipient" => user.email, 
        "from" => "jxxcarlson@gmail.com.io", 
        "subject" => "Verified!",
        "body" => "Congratulations, #{username}, your account is now verified.\n\n-- the kNode team"
      }
      render(conn, "account_is_verified.html") 
    else 
      err ->  render(conn, "sorry_not_verified.html")
    end
  end 

  def request_verification(conn, params) do 
     IO.puts "request_verification"
     render conn, "request_verification.html"
  end 

  def send_verification_email(conn, params) do 

    IO.inspect params, label: "PARAMS"
    user = User.get_user_by_email(params["email"])

    Email.email_html %{
      "recipient" => user.email, 
      "from" => "jxxcarlson@gmail.com.io", 
      "subject" => "Verify account",
      "body" => Email.verification_letter(user)
    }

    # render(conn, "verification_link_sent.html")

  end 


  def send_confirmation_email(conn, user) do
   
    Email.email_html %{
        "recipient" => user.email, 
        "from" => "jxxcarlson@gmail.com.io", 
        "subject" => "Congratulations!",
        "body" => Email.welcome_letter(user)
      }

    # render(conn, "reply.json", %{ reply: "Verification email sent to #{user.email}" }) 
    # conn 
  end

  def render_for_create_user conn, api_version, user do 
    case api_version do 
      "V1" ->  render(conn, "show_with_token.json", user: user)
      "V2" ->  render(conn, "return_token.json", user: user) 
      _ -> render(conn, "error.json", error: "Unknown API")
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
    IO.puts "UPDATE USER  #{id}"
    IO.inspect payload, label: "PAYLOAD"
    user_params = Koko.Utility.project2map(payload)
    user = Authentication.get_user!(id)
    with {:ok, user_id} <- Token.user_id_from_header(conn) ,
         {:ok, %User{} = user} <- Authentication.minimal_update_user(user, user_params)
    do    
         render(conn, "show.json", user: user)
    else 
        _ -> render(conn, "error.json", %{error: "Could not update user"})
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
    user = Authentication.get_user!(id)
    render(conn, "userstate.json", user: user)
  end


  def delete(conn, %{"id" => id}) do
    {:ok, token} = Token.token_from_header(conn)
    with  {:ok, admin_id} <- Token.user_id_from_header(conn),
      true <- admin_id == 1
    do
      user = Repo.get(User, id)
      Repo.delete(user)
      render(conn, "reply.json", reply: "deleted user #{id} (#{user.username})")
    else
      err -> render(conn, "reply.json", reply: "Could not delete user #{id}")

    end
  end

  def increment_media_count(conn, %{"id" => id}) do
    user = Authentication.get_user!(id)
    User.increment_media_count(user)
    render(conn, "reply.json", reply: "#{user.media_count + 1}")
  end

end
