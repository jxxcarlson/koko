defmodule Koko.Web.SessionView do
  use Koko.Web, :view
  alias Koko.Web.SessionView


  def render("show.json", %{token: token}) do
    %{token: token}
  end


end
