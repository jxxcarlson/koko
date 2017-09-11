defmodule Koko.Web.PublicDocumentControllerTest do
  use Koko.Web.ConnCase

  alias Koko.Document.DocManager
  alias Koko.User.Authentication
  alias Koko.Document.Query
  alias Koko.Document.Document
  alias Koko.Repo

  @create_attrs %{content: "some content", rendered_content: "some rendered_content", title: "some title",
     attributes: %{public: true}, identifier: "jxxcarlson.some_title.2017.777a"}
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

    n = Document |> Query.is_public |> Repo.all |> length

    conn = get conn, public_document_path(conn, :index)
    response = json_response(conn, 200)

    assert n == (response["documents"] |> length)
  end

end
