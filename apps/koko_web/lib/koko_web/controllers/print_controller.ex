defmodule Koko.Web.PrintController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.DocManager.Document

  plug :put_layout, false

  def fix_html(text, title, author) do
    IO.puts "ENTER fix_html for #{title}"
    "== #{title}\n=== by #{author}\n\n++++\n<br><br>\n++++\n\n" <>text
    |> String.replace("`", "!!aWz!!")
    |> String.replace("\\", "\\\\")
  end

  def show(conn, %{"id" => id}) do
    document = Repo.get(Document, String.to_integer(id))
    text_type = document.attributes["text_type"]
    title = document.title
    author = document.author_name
    case text_type do
      "plain" ->
        conn |> render("plain.html", text: document.rendered_content)
      "adoc" ->
        conn |> render("asciidoc.html", text: fix_html(document.content, title, author ))
      "adoc_latex" ->
          conn |> render("asciidoc.html", text: fix_html(document.content, title, author ))
      "latex" ->
        conn |> render("latex.html", text: document.content)
      _ ->
        conn |> render("asciidoc.html", text: fix_html(document.content, title, author))
    end
  end
end
