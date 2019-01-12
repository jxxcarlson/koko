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

  def process(conn, params) do

    IO.inspect params, label: "params for 'process'"
    {:ok, body, conn} = Plug.Conn.read_body(conn, length: 40_000_000)
    IO.inspect body, label: "BODY"

    bare_filename = params["filename"]
    tarfile = "#{bare_filename}.tar"
    texfile = params["filename"] <> ".tex"
    prefix = "printfiles/#{params["filename"]}"
    {:ok, cwd} = File.cwd
    File.mkdir_p prefix
    tar_path = "#{prefix}/#{tarfile}"
    IO.puts "PATH: " <> tar_path
    {:ok, file} = File.open tar_path, [:write]
    IO.binwrite file, body
    File.close file

    case File.read(tar_path) do
      {:ok, body} -> IO.puts "XX, TAR FILE EXISTS: #{tar_path}"
      {:error, reason} -> IO.puts "XX,  NO SUCH TAR FILE: #{tar_path}"
    end

    # System.cmd("tar", ["xvf", path])
    System.cmd("tar", ["-xf", tar_path, "-C", prefix ])
    File.cd prefix
    System.cmd("pdflatex", ["-interaction=nonstopmode", texfile])
    System.cmd("pdflatex", ["-interaction=nonstopmode", texfile])
    case File.read(texfile) do
      {:ok, body} -> IO.puts "XX, TEX FILE EXISTS: #{texfile}"
      {:error, reason} -> IO.puts "XX,  NO SUCH TEX FILE: #{texfiles}"
    end
    File.cd cwd

    conn |> render("pdf.json", url: bare_filename)
  end

  def display_pdf_file(conn, %{"filename" => filename}) do
    path = "printfiles/#{filename}/#{filename}.pdf"
    case File.read(path) do
      {:ok, body} -> Plug.Conn.send_file(conn, 200, path)
      {:error, reason} -> conn |> render("pdf_error.html", path: "Sorry, couldn't find the PDF file.")
    end
  end

end
