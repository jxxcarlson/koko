
defmodule Koko.Email do
  import Bamboo.Email

  alias Koko.Mailer


  def email(params) do
    if params["type"] == "html_text" do
      email_html(params)
    else
      email_plain(params)
    end
  end

  def email_html(params) do
    IO.puts "Email.email, sending to #{params["recipient"]}"
    new_email
    |> to(params["recipient"])
    |> from("support@node.io")
    |> subject(params["subject"])
    |> html_body(params["body"])
    |> Mailer.deliver_now
  end


  def email_plain(params) do
    IO.puts "Email.email, sending to #{params["recipient"]}"
    new_email
    |> to(params["recipient"])
    |> from("support@node.io")
    |> subject(params["subject"])
    |> text_body(params["body"])
    |> Mailer.deliver_now
  end



end
