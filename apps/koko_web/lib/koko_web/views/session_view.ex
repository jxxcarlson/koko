defmodule Koko.Web.SessionView do
  use Koko.Web, :view
  alias Koko.Web.SessionView

  def render("index.json", %{sessions: sessions}) do
    %{sessions: render_many(sessions, SessionView, "session.json")}
  end

  def render("show.json", %{session: session}) do
    %{session: render_one(session, SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{token: session.token}
  end
end
