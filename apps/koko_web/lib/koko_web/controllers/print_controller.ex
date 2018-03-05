defmodule Koko.Web.PrintController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.Document.Document

  plug :put_layout, false

  def fix_html(text, title, author) do
    title_string = "\n\n== #{title}\n=== by #{author}\n\n++++\n<br><br>\n++++\n\n"
    toc_and_title_string = ":toc:" <> title_string
    if String.contains? text, ":toc" do
              String.replace(text, ":toc:", toc_and_title_string)
            else
              title_string <> text
            end
    |> String.replace("`", "!!BT!!")
    |> String.replace("\\", "\\\\")
    |> String.replace("$", "!!DOL!!")
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
        conn |> render("latex.html", text: "\n\n$$\n\\newcommand{\\label}[1]{}" <> "\n$$\n\n" <> document.rendered_content)
      _ ->
        conn |> render("asciidoc.html", text: fix_html(document.content, title, author))
    end
  end
  
end
