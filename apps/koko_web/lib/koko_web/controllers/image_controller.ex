defmodule Koko.Web.ImageController do
    use Koko.Web, :controller

    alias Koko.User.Token
    alias Koko.Repo
    alias Koko.Image
    alias Koko.Document.Query
    alias Koko.Document.Search

  
    action_fallback Koko.Web.FallbackController

    def index(conn, _params) do 
      query_string = conn.query_string
      # images = cond do 
      #   query_string == "" -> Image |> Repo.all
      #   true -> Image |> Query.has_name(query_string) |> Repo.all
      # end 
      images = cond do
        query_string == "random=yes" -> Search.random_image("foo")
        true -> Search.by_query_string(:image, query_string, []) 
      end 
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
  