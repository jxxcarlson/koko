defmodule Koko.Web.AuthenticationView do
  use Koko.Web, :view


  def render("show.json", %{token: token}) do
    %{token: token}
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

end
