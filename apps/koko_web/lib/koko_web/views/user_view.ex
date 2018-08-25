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
      blurb: user.blurb,
      active: user.active,
      documentCount: user.document_count,
      mediaCount: user.media_count,
      verified: user.verified,
      public: user.public,
      created: user.inserted_at |> Calendar.NaiveDateTime.to_date_time_utc |> Calendar.DateTime.Format.unix 
    }
  end

  def render("userstate.json", %{user: user} ) do
    %{documentStack: user.document_ids, currentDocumentId: user.current_document_id, token: "foo"}
    # IO.inspect output, label: "USERSTATE.JSON"
    # output
  end

  def render("show_with_token.json", %{user: u}) do
    output =
     %{
        id: u.id,
        name: u.name,
        username: u.username,
        email: u.email,
        admin: u.admin,
        blurb: u.blurb,
        token: u.token,
        active: u.active
    }
    %{user: output}
  end

  def render("return_token.json", %{user: u}) do
    %{ token: u.token }
  end

  def render("error.json", %{error: error_message}) do
    %{error: error_message}
  end

  def render("reply.json", %{reply: reply}) do
    %{reply: reply}
  end

end
