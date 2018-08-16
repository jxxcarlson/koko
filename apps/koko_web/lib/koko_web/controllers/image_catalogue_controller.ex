defmodule Koko.Web.ImageCatalogueController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Latex.Parser

  plug :put_layout, false



  def show(conn, %{"id" => id}) do

    document = Repo.get(Document, String.to_integer(id))
    text_type = document.attributes["text_type"]
    case text_type do
      "latex" ->
        conn |> render( "latex.html", text: Parser.image_links(document.content), title: document.title )
      _ ->
        conn |> render( "latex.html", text: "No image catalogue for #{document.title}" )
    end

  end

end
