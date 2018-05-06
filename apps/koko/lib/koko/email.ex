# Define your emails
defmodule Koko.Email do
  import Bamboo.Email

  def test_email do
    new_email(
      to: "jxxcarlson@gmail.com",
      from: "support@knode.io",
      subject: "Test",
      html_body: "<strong>This is a test: only a test.</strong>",
      # text_body: "Thanks for joining!"
    )
    #
    # # or pipe using Bamboo.Email functions
    # new_email
    # |> to("foo@example.com")
    # |> from("me@example.com")
    # |> subject("Welcome!!!")
    # |> html_body("<strong>Welcome</strong>")
    # |> text_body("welcome")
  end

end
