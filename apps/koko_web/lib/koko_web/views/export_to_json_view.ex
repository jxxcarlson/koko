defmodule Koko.Web.ExportToJsonView do
    use Koko.Web, :view
     
    def render("show.json", %{data: text}) do
      %{data: text}
    end
  
end
  