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

end
