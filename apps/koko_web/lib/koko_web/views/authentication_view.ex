defmodule Koko.Web.AuthenticationView do
  use Koko.Web, :view


  def render("show.json", %{token: token}) do
    %{token: token}
  end

  def render("userstate.json", %{document_ids: document_ids, current_document_id: current_document_id} ) do
    %{document_ids: document_ids, current_document_id: current_document_id}
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

end
