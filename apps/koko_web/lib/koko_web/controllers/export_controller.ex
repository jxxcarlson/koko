defmodule Koko.Web.ExportController do
  use Koko.Web, :controller
  alias Koko.Repo
  alias Koko.Document.Document
  alias Koko.Latex.Parser

  plug :put_layout, false

  def export_latex(text, texmacros) do
    text2 = Parser.transform_images(text)
    prefix <> "\n\n" <> texmacros <> "\n\n" <> text2 <> suffix
  end

  def show(conn, %{"id" => id}) do
    document = Repo.get(Document, String.to_integer(id))
    author = Koko.User.Authentication.get_user!(document.author_id)
    IO.puts "author name: #{author.name }"
    results = Koko.Document.Search.by_query_string_for_user("title=texmacros", author.id)
    IO.puts "texmacro files found: #{length results}"
    texmacro_document = hd results
    texmacros = if texmacro_document != nil do
                   texmacro_document.content |> String.replace("$$", "")
                else
                   ""
    end


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
        conn |> render("latex.html", text: document.content |> export_latex(texmacros) )
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
    \\includegraphics[width=0.30\textwidth]{#1}
    \\caption{#2}
    \\centering
    \\end{figure}
}

\\newcommand{\\imagefloatright}[3]{
    \\begin{wrapfigure}{R}{0.30\\textwidth}
    \\includegraphics[width=0.30\\textwidth]{#1}
    \\caption{#2}
    \\end{wrapfigure}
}

\\newcommand{\\imagefloatleft}[3]{
    \\begin{wrapfigure}{L}{0.3-\\textwidth}
    \\includegraphics[width=0.30\\textwidth]{#1}
    \\caption{#2}
    \\end{wrapfigure}
}


\\newcommand{\\italic}[1]{{\\sl #1}}
\\newcommand{\\strong}[1]{{\\bf #1}}
\\newcommand{\\subheading}[1]{{\\bf #1}\\par}
\\newcommand{\\xlinkPublic}[2]{\\href{{http://www.knode.io/\\#@public#1}}{#2}}

\\newcommand{\\bibhref}[3]{[#3]\ \\href{#1}{#2}}

\\newtheorem{theorem}{Theorem}
\\newtheorem{axiom}{Axiom}
\\newtheorem{lemma}{Lemma}
\\newtheorem{proposition}{Proposition}
\\newtheorem{corollary}{Corollary}
\\newtheorem{definition}{Definition}
\\newtheorem{example}{Example}
\\newtheorem{exercise}{Exercise}
\\newtheorem{problem}{Problem}



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
