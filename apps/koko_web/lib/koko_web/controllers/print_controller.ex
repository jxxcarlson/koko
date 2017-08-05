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
    IO.puts "PRINT CONTROLLER, SHOW"
    document = Repo.get(Document, String.to_integer(id))
    IO.puts "Title: #{document.title}"
    IO.inspect document.attributes
    text_type = document.attributes["text_type"]
    IO.puts("text_type: #{text_type}")
    case text_type do
      "plain" ->
        IO.puts "Branch: PLAIN"
        conn |> render("plain.html", text: document.rendered_content)
      "adoc" ->
          IO.puts "Branch: ADOC"
        conn |> render("asciidoc.html", text: fix_html(document.content))
      "adoc_latex" ->
            IO.puts "Branch: ADOC LATEX"
          conn |> render("asciidoc.html", text: fix_html(document.content))
      "latex" ->
          IO.puts "Branch: LATEX"
        conn |> render("latex.html", text: document.content)
      _ ->
        IO.puts "Branch: DEFAULT"
        conn |> render("asciidoc.html", text: fix_html(document.content))
    end
  end
end
