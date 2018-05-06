defmodule Koko.Web.MailView do
  use Koko.Web, :view
  alias Koko.Web.MailView


def render("reply.json", %{message: message}) do
  %{message: message}
end


def render("error.json", %{error: error}) do
  %{error: error}
end

end
