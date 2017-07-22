defmodule Koko.Web.PrintController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.DocManager.Document

  plug :put_layout, false

  def fix_html(text) do
    text
    |> String.replace("`", "!!aWz!!")
    |> String.replace("\\", "\\\\")
  end

  def show(conn, %{"id" => id}) do
    document = Repo.get(Document, id)
    qs = conn.query_string
    case qs do
      "text=plain" ->
        conn |> render("plain.html", text: document.rendered_content)
      "text=adoc" ->
        conn |> render("asciidoc.html", text: fix_html(document.rendered_content))
      "text=latex" ->
        conn |> render("latex.html", text: document.rendered_content)
      _ ->
        conn |> render("plain.html", text: document.rendered_content)
    end
  end
end
