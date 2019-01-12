defmodule Koko.Web.PrintView do
  use Koko.Web, :view

  def render("pdf.json", %{url: url}) do
    %{url: url}
  end

end
