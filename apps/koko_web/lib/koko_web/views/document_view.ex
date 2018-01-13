defmodule Koko.Web.DocumentView do
  use Koko.Web, :view
  alias Koko.Web.DocumentView
  alias Koko.Document.Document

  def render("index.json", %{documents: documents}) do
    %{documents: render_many(documents, DocumentView, "document_loading.json")}
  end

  def render("index_loading.json", %{documents: documents}) do
    %{documents: render_many(documents, DocumentView, "document_loading.json")}
  end

  def render("show.json", %{document: document}) do
    %{document: render_one(document, DocumentView, "document.json")}
  end

  def render("document.json", %{document: document}) do
    %{id: document.id,
      identifier: document.identifier,
      author_id: document.author_id,
      author_name: document.author_name,
      title: document.title,
      content:  document.content,
      rendered_content:  document.rendered_content,
      attributes: document.attributes,
      tags: document.tags,
      children: document.children,
      parent_id: document.parent_id || 0,
      parent_title: Document.parent_title(document)
    }
  end

  def render("document_loading.json", %{document: document}) do
    %{id: document.id,
      identifier: document.identifier,
      author_id: document.author_id,
      author_name: document.author_name,
      title: document.title,
      content: "Loading ...", #document.content,
      rendered_content: "Loading ...", #document.rendered_content,
      attributes: document.attributes,
      tags: document.tags,
      children: document.children,
      parent_id: document.parent_id || 0,
      parent_title: Document.parent_title(document)
    }
  end
end
