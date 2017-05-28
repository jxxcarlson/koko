defmodule Koko.Web.AuthenticationView do
  use Koko.Web, :view
  alias Koko.Web.AuthenticationView


  def render("show.json", %{token: token}) do
    %{token: token}
  end


end
