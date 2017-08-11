defmodule Koko.Web.CredentialsView do
  use Koko.Web, :view

  def render("credentials.json", %{credentials: credentials}) do
    credentials
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end


end
