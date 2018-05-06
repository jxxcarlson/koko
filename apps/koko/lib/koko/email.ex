
defmodule Koko.Email do
  import Bamboo.Email

  alias Koko.Mailer

  def email(params) do
    IO.puts "Email.email, sending to #{params["recipient"]}"
    new_email
    |> to(params["recipient"])
    |> from("support@node.io")
    |> subject(params["subject"])
    |> html_body(params["body"])
    |> Mailer.deliver_now
  end

end
