defmodule Koko.Web.ImageView do
    use Koko.Web, :view
    alias Koko.Web.ImageView

    def render("index.json", %{images: images}) do
        %{images: render_many(images, ImageView, "image.json")}
    end

    def render("image.json", %{image: image}) do
        %{id: image.id, name: image.name, url: image.url}
    end
  
    def render("reply.json", params) do
        %{reply: params.reply}
    end

end