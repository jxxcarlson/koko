defmodule Koko.Web.ErrorView do
  use Koko.Web, :view

  def render("error.json", %{error: message}) do
    %{error: message}
  end

end
