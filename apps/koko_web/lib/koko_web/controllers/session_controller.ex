defmodule Koko.Web.SessionController do
  use Koko.Web, :controller

  alias Koko.Authentication
  alias Koko.Authentication.Session

  action_fallback Koko.Web.FallbackController

  def index(conn, _params) do
    sessions = Authentication.list_sessions()
    render(conn, "index.json", sessions: sessions)
  end

  def create(conn, %{"session" => payload}) do
    session_params = Koko.Utility.project2map(payload)
    IO.puts "----- session_params in session controller, create ----"
    IO.inspect session_params
    with {:ok, session} <- Authentication.create_session(session_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", session_path(conn, :show, session))
      |> render("show.json", session: session)
    end
  end

  def show(conn, %{"id" => id}) do
    session = Authentication.get_session!(id)
    render(conn, "show.json", session: session)
  end


  def delete(conn, %{"id" => id}) do
    session = Authentication.get_session!(id)
    with {:ok, %Session{}} <- Authentication.delete_session(session) do
      send_resp(conn, :no_content, "")
    end
  end
end
