defmodule Koko.Web.DocumentView do
  use Koko.Web, :view
  alias Koko.Web.DocumentView

  def render("index.json", %{documents: documents}) do
    %{documents: render_many(documents, DocumentView, "document.json")}
  end

  def render("show.json", %{document: document}) do
    %{document: render_one(document, DocumentView, "document.json")}
  end

  def render("document.json", %{document: document}) do
    %{id: document.id,
      title: document.title,
      content: document.content,
      rendered_content: document.rendered_content}
  end
end