defmodule Koko.Web.SessionController do
  use Koko.Web, :controller
  import Plug.Conn

  alias Koko.Authentication
  alias Koko.Authentication.Session

  # plug :scrub_params, "user" when action in [:create]
  # plug :actionP

  action_fallback Koko.Web.FallbackController

  def index(conn, _params) do
    sessions = Authentication.list_sessions()
    render(conn, "index.json", sessions: sessions)
  end

  def create(conn, %{"session" => payload}) do
    session_params = Koko.Utility.project2map(payload)
    with {:ok, token, user} <- Authentication.create_session(session_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", session_path(conn, :show, "headquarters"))
      |> render("show.json", token: token)
    end
  end


end
