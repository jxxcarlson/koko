defmodule Koko.Web.DocumentControllerTest do
  use Koko.Web.ConnCase

  alias Koko.DocManager
  alias Koko.DocManager.Document
  alias Koko.Authentication

  @create_attrs %{content: "some content", rendered_content: "some rendered_content", title: "some title",
     attributes: %{public: true}}
  @update_attrs %{content: "some updated content", rendered_content: "some updated rendered_content", title: "some updated title"}
  @invalid_attrs %{content: nil, rendered_content: nil, title: nil}

  @user_attrs %{"admin" => false, "blurb" => "BLURB!", "email" => "yozo@foo.io", "name" => "Yo T. Zo",
     "username" => "yozo", "password" => "yujo&$123"}

  def fixture(:document, attr) do
    {:ok, document} = DocManager.create_document(attr)
    document
  end

  def fixture(:user) do
    {:ok, user} = Authentication.create_user(@user_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
    # {:ok, user: fixture{:user}}
    # {:ok, tok, _} = Authentication.get_token(%{"email" => @user_attrs["email"], "password" => @user_attrs["password"]})
    # {:ok token: tok}
  end

  test "lists all PUBLIC entries on index", %{conn: conn} do
    user = fixture :user

    document_attributes = Map.merge(@create_attrs, %{author_id:  user.id})
    fixture :document, document_attributes

    n = Koko.DocManager.Search.for_public |> length

    conn = get conn, document_path(conn, :index_public)
    response = json_response(conn, 200)
    assert n == (response["documents"] |> length)
  end


  test "lists all USER entries on index" do
    user = fixture :user
    {:ok, token, _} = Authentication.get_token(%{"email" => user.email, "password" => user.password})

    document_attributes = Map.merge(@create_attrs, %{author_id:  user.id})
    fixture :document, document_attributes

    n = DocManager.list_documents(:user, user.id) |> length

    conn = build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/api/documents")

    assert n == json_response(conn, 200)["documents"] |> length
  end

  test "creates document and renders document when data is valid", %{conn: conn} do

    conn = post conn, document_path(conn, :create), document: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["document"]

    conn = get conn, document_path(conn, :show, id)
    document = json_response(conn, 200)["document"]
    assert document["id"] == id
    # assert json_response(conn, 200)["document"] == %{
    #   "id" => id,
    #   "content" => "some content",
    #   "rendered_content" => "some rendered_content",
    #   "title" => "some title"}
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
