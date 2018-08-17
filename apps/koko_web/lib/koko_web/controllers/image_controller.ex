defmodule Koko.Web.ImageController do
    use Koko.Web, :controller

    alias Koko.User.Token
    alias Koko.Repo
    alias Koko.Image

  
    action_fallback Koko.Web.FallbackController

    def index(conn, _params) do  
      images = Image |> Repo.all
      render(conn, "index.json", %{images: images})
    end
  
    def create(conn, params) do
      IO.inspect params, label: "image_params"
      cs = Image.changeset(%Image{}, params)
      IO.inspect cs, label: "changeset"
      Repo.insert(cs)
      render(conn, "reply.json", reply: "OK, boss!")
    end 
  
  end
  