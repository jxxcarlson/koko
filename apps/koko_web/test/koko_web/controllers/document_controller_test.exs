defmodule Koko.Web.DocumentControllerTest do
  use Koko.Web.ConnCase, async: true

  alias Koko.Document.DocManager
  alias Koko.User.Authentication
  alias Koko.Document.Search

  # https://hexdocs.pm/phoenix/Phoenix.ConnTest.html

  @create_attrs %{content: "some content", rendered_content: "some rendered_content", title: "Introductory Magick",
     attributes: %{public: false}, identifier: "jxxcarlson.some_title.2017.777a"}
  @update_attrs %{content: "some updated content", rendered_content: "some updated rendered_content", title: "Bio 101"}
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


  describe "index" do

    test "lists all USER entries on index" do
      [user, token, _] = set_values()

      n = Search.by_query_string_for_user("", user.id) |> length

      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/documents")

      assert n == json_response(conn, 200)["documents"] |> length
    end

    test "find documents for user with title 'Introductory Magick'" do
      [_, token, _] = set_values()
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/documents?title=magick")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found == 1
    end

    test "find children of master document" do
      password = System.get_env("KOKO_PASSWORD")
      email = System.get_env("KOKO_EMAIL")
      {:ok, token, _username} = Authentication.get_token %{"email" => email, "password" => password}
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/documents?master=365")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found  == 24
    end

    test "find random public documents" do
      [_, token, _] = set_values()
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/documents?random=public")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found > 5
    end

    test "find random documents" do
      [_, token, _] = set_values()
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/documents?random=all")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found > 5
    end

    test "find random documents for user" do
      [_, token, _] = set_values()
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/documents?random_user=1")

      number_of_documents_found = json_response(conn, 200)["documents"] |> length
      assert number_of_documents_found > 5
    end

  end

  describe "show"  do

  end

  describe "create" do

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

      token =  "aaa.bbb.ccc"

      conn = setup_conn(token)
        |> (post "/api/documents/", %{document: @create_attrs})

      # conn = post conn, document_path(conn, :create), document: @invalid_attrs
      assert json_response(conn, 404) ==  %{"error" => "Could not get verified user ID"}
    end

  end

  describe "update" do

    test "updates chosen document and renders document when data is valid" do
      [_, token, document] = set_values()
      id = document.id

      conn = setup_conn(token)
        |> (put "/api/documents/#{id}", %{document: @update_attrs})

      assert %{"id" => ^id} = json_response(conn, 200)["document"]

      conn = setup_conn(token)
        |> (get "/api/documents/#{id}")

      response =  json_response(conn, 200)["document"]
       |> Map.delete("id") |> Map.delete("author_id")

      assert response ==  %{"content" => "some updated content",
        "rendered_content" => "some updated rendered_content",
        "tags" => nil, "title" =>
        "Bio 101",
        "attributes" => %{"doc_type" => "standard", "public" => false,
           "text_type" => "adoc", "level" => 0},
           "identifier" => "jxxcarlson.introductory_magick.2017.777a",
           "author_name" => nil, "children" => [],
           "parent_id" => 0, "parent_title" => ""
         }
    end

    test "does not update chosen document when not authorized" do
      [_, _, document] = set_values()
      # id = document.id
      token = "aaa.bbb.ccc"

      conn = setup_conn(token)
        |> (put "/api/documents/#{document.id}", %{"document": @invalid_attrs})

      assert json_response(conn, 404) == %{"error" => "Could not get verified user ID"}
    end

  end



  describe "delete " do

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



end
