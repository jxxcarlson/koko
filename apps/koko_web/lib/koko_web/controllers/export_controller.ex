defmodule Koko.Web.ExportController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Document.MasterDocument
  alias Koko.Document.Latex

  plug :put_layout, false
 

  def show(conn, %{"id" => id}) do
    document = Repo.get(Document, String.to_integer(id))
    doc_type = document.attributes["doc_type"]
    if doc_type == "master" do
      export_master_latex_document(conn, document)
    else
      export_standard_document(conn, document)
    end
  end


  defp export_master_latex_document(conn, document) do
    conn |> render("latex.html", text: Latex.prepare_master_for_export(document) )
  end

  defp export_standard_document(conn, document) do
    text_type = document.attributes["text_type"]
    case text_type do
      "plain" ->
        conn |> render("plain.html", text: document.rendered_content)
      "adoc" ->
        conn |> render("asciidoc.html", text: document.content)
      "adoc_latex" ->
          conn |> render("asciidoc.html", text: document.content)
      "latex" ->
        conn |> render("latex.html", text: Latex.prepare_for_export(document) )
      _ ->
        conn |> render("asciidoc.html", text: document.content)
    end
  end

  

end
