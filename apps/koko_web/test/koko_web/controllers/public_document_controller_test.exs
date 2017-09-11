defmodule Koko.Web.PublicDocumentControllerTest do
  use Koko.Web.ConnCase

  alias Koko.Document.DocManager
  alias Koko.User.Authentication
  alias Koko.Document.Query
  alias Koko.Document.Document
  alias Koko.Repo

  @create_attrs %{content: "some content", rendered_content: "some rendered_content", title: "Introductory Magick",
     attributes: %{public: true, "foo": "bar"}, identifier: "jxxcarlson.some_title.2017.777a"}
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




  describe "index" do

    test "lists all PUBLIC entries on index", %{conn: conn} do
      user = fixture :user

      document_attributes = Map.merge(@create_attrs, %{author_id:  user.id})
      fixture :document, document_attributes

      n = Document |> Query.is_public |> Repo.all |> length

      conn = get conn, public_document_path(conn, :index)
      response = json_response(conn, 200)

      assert n == (response["documents"] |> length)
    end

    test "find documents for user with title 'Introductory Magick'" do
      user = fixture :user
      document_attributes = Map.merge(@create_attrs, %{author_id:  user.id})
      fixture :document, document_attributes

      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> get("/api/public/documents?title=magick")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found == 1
    end

    test "find children of master document" do
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> get("/api/public/documents?master=365")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found  == 21
    end

    test "find random public documents" do
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> get("/api/public/documents?random=public")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found > 5
    end

    test "find random documents" do
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> get("/api/public/documents?random=all")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found > 5
    end

    test "find random documents for user" do
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> get("/api/public/documents?random_user=1")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found > 5
    end

  end

end
