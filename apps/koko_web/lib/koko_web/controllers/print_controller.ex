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


    {:ok, body, conn} = Plug.Conn.read_body(conn, length: 40_000_000)

    # SET PATHS
    bare_filename = params["filename"]
    IO.puts "bare_filename = #{bare_filename}"
    tarfile = "#{bare_filename}.tar"
    texfile = bare_filename <> ".tex"
    pdffile = bare_filename <> ".pdf"
    prefix = "printfiles/#{bare_filename}"
    filepath = "printfiles/#{bare_filename}/files"
    texfile_path = "files/#{texfile}"

    # CHECK CURRENT WORKING DIRECTORY
    File.cd home
    {:ok, cwd} = File.cwd
    IO.puts "CWD: #{cwd}"

    # MAKE PATH FOR TAR ARCHIVE
    File.mkdir_p prefix
    tar_path = "#{prefix}/#{tarfile}"
    IO.puts "PATH: " <> tar_path
    {:ok, file} = File.open tar_path, [:write]
    IO.binwrite file, body
    File.close file

    # CHECK THAT TAR PATH EXISTS
    case File.read(tar_path) do
      {:ok, body} -> IO.puts "XX, TAR FILE EXISTS: #{tar_path}"
      {:error, reason} -> IO.puts "XX,  NO SUCH TAR FILE: #{tar_path}"
    end

    # EXTRACT TAR ARCHIVE AND CHANGE DIRECTORY TO WHERE THE ARCHIVE IS
    System.cmd("tar", ["-xvf", tar_path, "-C", prefix ])
    File.cd filepath
    {:ok, cwd} = File.cwd
    IO.puts "VERIFY CWD FOR FILES: #{cwd}"
    IO.inspect (File.ls)

    # VERIFY THAT THE TEX FILE IS WHERE IT SHOULD BE
    case File.read(texfile) do
      {:ok, body} -> IO.puts "TEX FILE EXISTS: #{texfile}"
      {:error, reason} -> IO.puts "NO SUCH TEX FILE: #{texfile}"
    end

    # VERIFY THAT PDFLATEX IS THERE
    {message, _} = System.cmd("pdflatex" , ["--version"])
    IO.puts message

    IO.puts "Running pdflatex (1) on file: #{texfile_path}"

    {errors, _} = System.cmd("pdflatex", ["-interaction=nonstopmode", texfile], stderr_to_stdout: true)
    IO.puts "TEX errors: #{errors}"
    # System.cmd("pdflatex", ["-interaction=nonstopmode", texfile], stderr_to_stdout: true)

    case File.read(pdffile) do
      {:ok, body} -> IO.puts "(1) PDF FILE EXISTS: #{pdffile}"
      {:error, reason} -> IO.puts "(1)  NO SUCH PDF FILE: #{pdffile}"
    end

    IO.puts "Running pdflatex (2) on file: #{texfile}"
    System.cmd("pdflatex", ["-interaction=nonstopmode", texfile], stderr_to_stdout: true)

    case File.read(pdffile) do
      {:ok, body} -> IO.puts "(2) PDF FILE EXISTS: #{pdffile}"
      {:error, reason} -> IO.puts "(2)  NO SUCH PDF FILE: #{pdffile}"
    end

    File.cd home

    conn |> render("pdf.json", url: bare_filename)
  end

  def reset(conn, params) do

    File.cd home
    bare_filename = params["filename"]
    IO.puts "bare_filename = #{bare_filename}"
    archive = "printfiles/#{bare_filename}"
    :timer.sleep(10000);
    File.rm_rf(archive)

    conn |> render("resetarchive.json", message: bare_filename)
  end

  def display_pdf_file(conn, %{"filename" => filename}) do

    prefix = "printfiles/#{filename}"

    pdf_path = "printfiles/#{filename}/files/#{filename}.pdf"

    IO.puts "XXXX: This is DISPLAY PDF FILE"

    File.cd home
    # File.cd prefix

    {:ok, cwd} = File.cwd
    IO.puts "CWD, display: #{cwd}"


    case File.read(pdf_path) do
      {:ok, body} -> IO.puts "Found the pdf file at #{pdf_path}"
      {:error, reason} -> "Could NOT find the pdf file at #{pdf_path}"
    end

    case File.read(pdf_path) do
      {:ok, body} -> Plug.Conn.send_file(conn, 200, pdf_path)
      {:error, reason} -> conn |> render("pdf_error.html", path: "No PDF file at #{[pdf_path]}")
    end

  end

end
