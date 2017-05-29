defmodule Koko.Web.DocumentControllerTest do
  use Koko.Web.ConnCase

  alias Koko.DocManager
  alias Koko.Repo
  alias Koko.DocManager.Document

  @create_attrs %{content: "some content", rendered_content: "some rendered_content", title: "some title"}
  @update_attrs %{content: "some updated content", rendered_content: "some updated rendered_content", title: "some updated title"}
  @invalid_attrs %{content: nil, rendered_content: nil, title: nil}

  def fixture(:document) do
    {:ok, document} = DocManager.create_document(@create_attrs)
    document
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    n = Repo.all(Document) |> length
    conn = get conn, document_path(conn, :index)
    nn =json_response(conn, 200)["documents"] |> length
    assert n == nn
  end

  test "creates document and renders document when data is valid", %{conn: conn} do
    conn = post conn, document_path(conn, :create), document: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["document"]

    conn = get conn, document_path(conn, :show, id)
    assert json_response(conn, 200)["document"] == %{
      "id" => id,
      "content" => "some content",
      "rendered_content" => "some rendered_content",
      "title" => "some title"}
  end

  test "does not create document and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, document_path(conn, :create), document: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen document and renders document when data is valid", %{conn: conn} do
    %Document{id: id} = document = fixture(:document)
    conn = put conn, document_path(conn, :update, document), document: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["document"]

    conn = get conn, document_path(conn, :show, id)
    assert json_response(conn, 200)["document"] == %{
      "id" => id,
      "content" => "some updated content",
      "rendered_content" => "some updated rendered_content",
      "title" => "some updated title"}
  end

  test "does not update chosen document and renders errors when data is invalid", %{conn: conn} do
    document = fixture(:document)
    conn = put conn, document_path(conn, :update, document), document: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen document", %{conn: conn} do
    document = fixture(:document)
    conn = delete conn, document_path(conn, :delete, document)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, document_path(conn, :show, document)
    end
  end
end
