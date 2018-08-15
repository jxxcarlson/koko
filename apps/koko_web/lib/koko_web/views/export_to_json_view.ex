defmodule Koko.Web.ExportToJsonView do
    use Koko.Web, :view
     
    def render("show.json", %{data: text}) do
      %{data: text}
    end

    def render("image_list.json", %{data: image_list}) do
      %{data: image_list}
    end
  
end
  