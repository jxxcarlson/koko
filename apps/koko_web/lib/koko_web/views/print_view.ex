defmodule Koko.Web.PrintView do
  use Koko.Web, :view

  def render("pdf.json", %{url: url}) do
    String.replace url, "\"", "" 
  end

end
