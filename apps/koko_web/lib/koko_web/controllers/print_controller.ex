defmodule Koko.Web.PrintController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.DocManager.Document

  plug :put_layout, false

  def show(conn, %{"id" => id}) do
    document = Repo.get(Document, id)
    qs = conn.query_string
    case qs do
      "text=plain" ->
        conn |> render("plain.html", document: document)
      "text=adoc" ->
        conn |> render("asciidoc.html", document: document)
      "text=latex" ->
        conn |> render("latex.html", document: document)
      _ ->
        conn |> render("plain.html", document: document)
    end
  end
end
