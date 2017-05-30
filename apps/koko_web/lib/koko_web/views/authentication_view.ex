defmodule Koko.Web.AuthenticationView do
  use Koko.Web, :view


  def render("show.json", %{token: token}) do
    %{token: token}
  end


end
