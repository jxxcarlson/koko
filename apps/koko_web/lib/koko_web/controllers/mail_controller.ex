defmodule Koko.Web.MailController do
  use Koko.Web, :controller

  alias Koko.User.Token
  alias Koko.Repo
  alias Koko.Email
  alias Koko.Mailer


  action_fallback Koko.Web.FallbackController

  def test(conn, %{"command" => command}) do

    if command == "abc" do
      Email.test_email |> Mailer.deliver_now
    end

    render(conn, "reply.json", message: command)
  end


  # params: %{"subject" => SUBJECT, "recipient" => RECIPIENT, "body" => BODY}
  def mail(conn, params) do
    IO.inspect params
    IO.inspect Token.user_id_from_header(conn), label: "Token"
    with {:ok, user_id} <- Token.user_id_from_header(conn) do
       if user_id == 1 do 
         Email.email(params)
         render(conn, "reply.json", message: "Email sent for #{params["recipient"]}")
       else 
         render(conn, "error.json", error: "Mailer error (1)")
       end
    else
       _ -> render(conn, "error.json", error: "Mailer error (2)")
    end

  end


end
