defmodule Koko.Web.DocumentControllerTest do
  use Koko.Web.ConnCase

  alias Koko.DocManager
  alias Koko.Authentication

  # https://hexdocs.pm/phoenix/Phoenix.ConnTest.html

  @create_attrs %{content: "some content", rendered_content: "some rendered_content", title: "some title",
     attributes: %{public: true}}
  @update_attrs %{content: "some updated content", rendered_content: "some updated rendered_content", title: "some updated title"}
  @invalid_attrs %{content: "uuu"}
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

  def set_values do
    user = fixture :user
    {:ok, token, _} = Authentication.get_token(%{"email" => user.email, "password" => user.password})
    document_attributes = Map.merge(@create_attrs, %{author_id:  user.id})
    document = fixture :document, document_attributes
    [user, token, document]
  end

  def setup_conn(token) do
    build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")
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
    [user, token, _] = set_values()

    n = DocManager.list_documents(:user, user.id) |> length

    conn = build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/api/documents")

    assert n == json_response(conn, 200)["documents"] |> length
  end

  test "creates document and renders document when data is valid" do
    [_, token, _] = set_values()

    conn = setup_conn(token)
      |> (post "/api/documents/", %{document: @create_attrs})

    assert %{"id" => id} = json_response(conn, 201)["document"]

    conn = setup_conn(token)
      |> (get "/api/documents/#{id}")

    document = json_response(conn, 200)["document"]
    assert document["id"] == id
  end

  test "does not create document and renders errors when request is not authorized" do
    [_, _, _] = set_values()

    token =  "aaa.bbb.ccc"

    conn = setup_conn(token)
      |> (post "/api/documents/", %{document: @create_attrs})

    # conn = post conn, document_path(conn, :create), document: @invalid_attrs
    assert json_response(conn, 404) ==  %{"error" => "Could not get verified user ID"}
  end

  test "updates chosen document and renders document when data is valid" do
    [user, token, document] = set_values()
    id = document.id

    conn = setup_conn(token)
      |> (put "/api/documents/#{id}", %{document: @update_attrs})

    assert %{"id" => ^id} = json_response(conn, 200)["document"]

    conn = setup_conn(token)
      |> (get "/api/documents/#{id}")

    assert json_response(conn, 200)["document"] == %{
      "id" => id,
      "content" => "some updated content",
      "author_id" => user.id,
      "title" => "some updated title"}
  end

  test "does not update chosen document when not authorized" do
    [_, _, document] = set_values()
    # id = document.id
    token = "aaa.bbb.ccc"

    conn = setup_conn(token)
      |> (put "/api/documents/#{document.id}", %{"document": @invalid_attrs})

    assert json_response(conn, 404) == %{"error" => "Could not get verified user ID"}
  end

  test "deletes chosen document" do
    [_, token, document] = set_values()
    id = document.id

    conn = setup_conn(token)
      |> (delete "/api/documents/#{id}")

    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, document_path(conn, :show, document)
    end
  end
end
