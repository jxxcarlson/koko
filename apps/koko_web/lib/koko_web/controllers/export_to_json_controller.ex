defmodule Koko.Web.ExportToJsonController do
    use Koko.Web, :controller
    alias Koko.Repo
    alias Koko.Document.Document
    alias Koko.Document.MasterDocument
    alias Koko.Latex.Parser
    alias Koko.Document.Latex
  
    plug :put_layout, false
  
    def show(conn, %{"id" => id}) do

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


    def image_list(conn, %{"id" => id}) do
        document = Repo.get(Document, String.to_integer(id))
        conn |> render("image_list.json", %{data: image_list_(document)})   
    end
  

    # Master document -> String
    defp collate(document) do
        document
          |> MasterDocument.id_list
          |> Document.concatenate_source
    end


    # Document -> List String
    defp image_list_(document) do
        doc_type = document.attributes["doc_type"]
        if doc_type == "master" do
            document |> collate |> Parser.image_url_list
        else
            document.content |> Parser.image_url_list
        end
    end
  
  end
  