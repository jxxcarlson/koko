defmodule Koko.Web.ExportController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Latex.Parser

  plug :put_layout, false

  def export_latex text do
    text2 = Parser.transform_images(text)
    prefix <> text2 <> suffix
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
        conn |> render("asciidoc.html", text: document.content)
      "adoc_latex" ->
          conn |> render("asciidoc.html", text: document.content)
      "latex" ->
        conn |> render("latex.html", text: document.content |> export_latex )
      _ ->
        conn |> render("asciidoc.html", text: document.content)
    end
  end



def prefix() do
    """
\\documentclass[11pt, oneside]{article}
\\usepackage{geometry}
\\geometry{letterpaper}

\\usepackage{graphicx}
\\usepackage{wrapfig}
\\graphicspath{ {images/} }

\\usepackage{amssymb}
\\usepackage{amsmath}
\\usepackage{hyperref}
\\hypersetup{
    colorlinks=true,
    linkcolor=blue,
    filecolor=magenta,
    urlcolor=blue,
}

%SetFonts

%SetFonts

%%%%%%
\\newcommand{\\code}[1]{{\\tt #1}}
\\newcommand{\\ellie}[1]{\\href{#1}{Link to Ellie}}
% \\newcommand{\\image}[3]{\\includegraphics[width=3cm]{#1}}

\\newcommand{\\imagecenter}[3]{
    \\begin{figure}[h]
    \\includegraphics[width=7cm]{#1}
    \\centering
    \\end{figure}
}

\\newcommand{\\imagefloatright}[3]{
    \\begin{wrapfigure}{r}{0.25\\textwidth}
    \\includegraphics[width=3cm]{#1}
    \\centering
    \\end{wrapfigure}
}

\\newcommand{\\imagefloatleft}[3]{
     \\begin{wrapfigure}{l}{0.25\\textwidth}
    \\includegraphics[width=7cm]{#1}
    \\centering
    \\end{wrapfigure}
}

\\newcommand{\\italic}[1]{{\\sl #1}}
\\newcommand{\\strong}[1]{{\\bf #1}}
\\newcommand{\\subheading}[1]{{\\bf #1}\\par}
\\newcommand{\\xlinkPublic}[2]{\\href{{http://www.knode.io/\\#@public#1}}{#2}}


%%The http://www.knode.io/@public

\\newtheorem{theorem}{Theorem}

\\parindent0pt
\\parskip10pt

\\begin{document}


"""
end

def suffix() do
    """

\\end{document}
"""
end

end
