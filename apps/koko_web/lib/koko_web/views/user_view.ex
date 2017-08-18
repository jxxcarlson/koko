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
      password: "-",
      token: "-",
      email: user.email,
      admin: user.admin,
      blurb: user.blurb}
  end

  def render("show_with_token.json", %{user: u}) do
     %{id: u.id,
      name: u.name,
      username: u.username,
      email: u.email,
      admin: u.admin,
      blurb: u.blurb,
      token: u.token}
  end

  def render("error.json", %{error: error_message}) do
    %{error: error_message}
  end

end
