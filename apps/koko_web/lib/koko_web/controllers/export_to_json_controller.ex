defmodule Koko.Web.ExportToJsonController do
    use Koko.Web, :controller
    alias Koko.Repo
    alias Koko.Document.Document
    alias Koko.Document.MasterDocument
    alias Koko.Latex.Parser
    alias Koko.Document.Latex
  
    plug :put_layout, false
  
    def show(conn, %{"id" => id}) do
      IO.puts "AAAA"
      document = Repo.get(Document, String.to_integer(id))
      doc_type = document.attributes["doc_type"]
      if doc_type == "master" do
        export_master_latex_document_to_json(conn, document)
      else
        export_standard_document_to_json(conn, document)
      end
    end
  
    defp export_standard_document_to_json(conn, document) do
      conn |> render("show.json", %{data: Latex.prepare_for_export(document)} )
    end
  
  
    defp export_master_latex_document_to_json(conn, document) do
      conn |> render("show.json", %{data: Latex.prepare_master_for_export(document)})
    end
  


  
  end
  