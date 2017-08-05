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
    document = Repo.get(Document, id)
    IO.puts "Title: #{document.title}"
    IO.inspect document.attributes
    text_type = document.attributes["text_type"]
    IO.puts("text_type: #{text_type}")
    IO.puts("RC: #{document.rendered_content}")
    case text_type do
      "plain" ->
        conn |> render("plain.html", text: document.rendered_content)
      "adoc" ->
        conn |> render("asciidoc.html", text: fix_html(document.rendered_content))
      "latex" ->
        conn |> render("latex.html", text: document.rendered_content)
      _ ->
        conn |> render("plain.html", text: document.rendered_content)
    end
  end
end
