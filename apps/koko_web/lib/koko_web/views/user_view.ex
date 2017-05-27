defmodule Koko.Web.UserView do
  use Koko.Web, :view
  alias Koko.Web.UserView

  def render("index.json", %{users: users}) do
    %{users: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
      admin: user.admin,
      blurb: user.blurb}
  end
end