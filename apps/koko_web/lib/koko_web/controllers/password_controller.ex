defmodule Koko.Web.PasswordController do
  use Koko.Web, :controller

  alias Koko.User.Token
  alias Koko.Repo
  alias Koko.Email
  alias Koko.Mailer

  action_fallback Koko.Web.FallbackController

  plug :put_layout, false

  def show_request_form(conn, params) do
    render conn, "request_reset.html"
  end


  def user_token(user) do
    {:ok, token} = Koko.User.Token.get(user.id, user.username, 30*60)
    token
  end

  def reset_email_body(email) do
    user = Koko.User.Query.get_by_email(email)
    if user == nil do
      send_error_message
    else
      send_reset_message(user)
    end
  end

  def send_error_message do
    """
    Sorry, we could not find that email.
    """
  end

  def send_reset_message(user) do
    """
    Please click on
    <a href="https://nshost.herokuapp.com/api/password/form?#{user_token(user)}">this link</a>
    to get a form to reset your password.
    """
  end

  def mail_reset_link(conn, params) do
    mail_params = %{"subject" => "Password reset",
      "recipient" => params["email"],
      "body" => reset_email_body(params["email"]),
      "type" => "html_text"
    }
    Email.email(mail_params)
    render conn, "ok_email.html"
  end


  def show_reset_form(conn, _params) do
    IO.puts "show_reset_form, query string = #{conn.query_string}"
     render conn, "reset.html", token: conn.query_string
  end

  def validate_token(token) do
    with {:ok, payload} <- Token.payload(token),
      true <- Token.authenticated(token, payload["user_id"])
    do
      {:ok, payload["username"]}
    else
      err -> {:error, "Invalid token"}
    end
  end

  def validate_password(password, password2) do
    if password == password2 do
      {:ok, password}
    else
      {:error, "Passwords do not match"}
    end
  end

  def reset_password(conn, params) do
    IO.puts "RESET PASSWORD"
    IO.inspect params
    IO.puts "================="
    with {:ok, username} <- validate_token(params["token"]),
      {:ok, password} <- validate_password(params["password"], params["password2"])
    do
      case do_reset_password(username, password) do
        {:ok, _} -> render conn, "ok_reset.html"
        {:error, _} -> render conn, "sorry.html"
      end
    else
      err -> render conn, "sorry.html"
    end
  end

  def do_reset_password(username, password) do
    user = Koko.User.Query.get_by_username(username)
    if user != nil do
      user
      |> Koko.User.User.registration_changeset(%{password: password})
      |> Repo.update()
      {:ok, "password is changed"}
    else
      {:error, "could not change password"}
    end
  end




end
