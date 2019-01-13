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

  def home do
    "/app"
    #{ }"/Users/carlson/dev/apps/MiniLatexProject/koko"
  end

  def process(conn, params) do

    File.cd home
    IO.inspect params, label: "params for 'process'"
    {:ok, body, conn} = Plug.Conn.read_body(conn, length: 40_000_000)
    IO.inspect body, label: "BODY"

    bare_filename = params["filename"]
    IO.puts "bare_filename = #{bare_filename}"
    tarfile = "#{bare_filename}.tar"
    texfile = bare_filename <> ".tex"
    pdffile = bare_filename <> ".pdf"
    prefix = "printfiles/#{params["filename"]}"

    {:ok, cwd} = File.cwd
    IO.puts "CWD: #{cwd}"

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

    System.cmd("tar", ["-xf", tar_path, "-C", prefix ])
    File.cd prefix
    {:ok, cwd} = File.cwd
    IO.puts "change directory, CWD: #{cwd}"

    case File.read(texfile) do
      {:ok, body} -> IO.puts "TEX FILE EXISTS: #{texfile}"
      {:error, reason} -> IO.puts "NO SUCH TEX FILE: #{texfile}"
    end

    {message, _} = System.cmd("pdflatex" , ["--version"])
    IO.puts message

    IO.puts "Running pdflatex (1) ..."

    {errors, _} = System.cmd("pdflatex", ["-interaction=nonstopmode", texfile], stderr_to_stdout: true)
    IO.puts "TEX errors: #{errors}"
    # System.cmd("pdflatex", ["-interaction=nonstopmode", texfile], stderr_to_stdout: true)

    case File.read(pdffile) do
      {:ok, body} -> IO.puts "(1) PDF FILE EXISTS: #{pdffile}"
      {:error, reason} -> IO.puts "(1)  NO SUCH PDF FILE: #{pdffile}"
    end

    IO.puts "Running pdflatex (2) ..."
    System.cmd("pdflatex", ["-interaction=nonstopmode", texfile], stderr_to_stdout: true)

    case File.read(pdffile) do
      {:ok, body} -> IO.puts "(2) PDF FILE EXISTS: #{pdffile}"
      {:error, reason} -> IO.puts "(2)  NO SUCH PDF FILE: #{pdffile}"
    end

    File.cd home

    conn |> render("pdf.json", url: bare_filename)
  end

  def display_pdf_file(conn, %{"filename" => filename}) do

    File.cd home

    {:ok, cwd} = File.cwd
    IO.puts "CWD, display: #{cwd}"
    path = "printfiles/#{filename}/#{filename}.pdf"

    case File.read(path) do
      {:ok, body} -> Plug.Conn.send_file(conn, 200, path)
      {:error, reason} -> conn |> render("pdf_error.html", path: "No PDF file (#{path})")
    end

  end

end
