defmodule Koko.Web.ExportToJsonView do
    use Koko.Web, :view
     
    def render("show.json", %{latex: text}) do
      %{latex: text}
    end
  
end
  