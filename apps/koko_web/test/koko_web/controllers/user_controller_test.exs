defmodule Koko.Web.UserControllerTest do
  use Koko.Web.ConnCase

  alias Koko.User.Authentication
  alias Koko.Repo
  alias Koko.User.User

  @create_attrs %{"admin" => true, "blurb" => "BLURB!", "email" => "yozo@foo.io", "name" => "Yo T. Zo",
     "username" => "yozo", "password" => "yujo&$123", "document_ids" => [1,2,3], "current_document_id" => 1}

  # @create_attrs %{admin: true, blurb: "some blurb", email: "some email", name: "some name", password_hash: "some password_hash", username: "some username"}
  # @update_attrs %{admin: false, blurb: "Superman rocks!", email: "Updated email", name: "Upated updated name = Bimto",
  #    username: "Filmore Yurtick", "password": "yujo&$123"}
  #
  @update_attrs %{admin: false, blurb: "Superman rocks!", username: "Filmore Yurtick"}

  @invalid_attrs %{admin: nil, blurb: nil, email: nil, name: nil, password_hash: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Authentication.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    n = Repo.all(User)|> length
    conn = get conn, user_path(conn, :index)
    nn = json_response(conn, 200)["users"] |> length
    assert n == nn
  end

  test "creates user and renders user when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["user"]
    conn = get conn, user_path(conn, :show, id)
    assert json_response(conn, 200)["user"]["username"] == "yozo"
    assert json_response(conn, 200)["id"] > 0
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: %{user: @invalid_attrs}
    assert json_response(conn, 200) == %{"error" => "Username must have at least four characters."}
  end

  test "updates updateable attributes of chosen user_available", %{conn: conn} do
    user = fixture(:user)
    conn = put conn, user_path(conn, :update, user, user: @update_attrs)
    response = json_response(conn, 200)
    id =  response["user"]["id"]
    assert id > 0
    assert response["user"]["blurb"] == "Superman rocks!"

    conn = get conn, user_path(conn, :show, id)
    response2 = json_response(conn, 200)
    assert response2["user"]["blurb"] == "Superman rocks!"
  end

  test "nonupdateable attributes of chosen user are not changed", %{conn: conn} do
    user = fixture(:user)
    conn = put conn, user_path(conn, :update, user, user: @update_attrs)
    response = json_response(conn, 200)
    assert response["user"]["username"] == "yozo"
    id =  response["user"]["id"]
    assert id > 0

    conn = get conn, user_path(conn, :show, id)
    response2 = json_response(conn, 200)
    assert response2["user"]["username"] == "yozo"

  end

  test "getuserstate works", %{conn: conn} do
    user = fixture(:user)
    conn = get conn, user_path(conn, :getuserstate, user, id: user.id)
    response = json_response(conn, 200)
    IO.inspect user, label: "user"
    IO.inspect response, label: "response"
    assert response["documentStack"]== [1,2,3]
  end

  # XXX: work tests below

  # test "does not update chosen user and renders errors when data is invalid", %{conn: conn} do
  #   user = fixture(:user)
  #   conn = put conn, user_path(conn, :update, user), user: %{user: @invalid_attrs}
  #   IO.inspect json_response(conn, 200), label: "RESPONSE!!"
  #   assert json_response(conn, 200)["errors"] != %{}
  # end

  # Have not yet permitted user deletion in router
  # test "deletes chosen user", %{conn: conn} do
  #   user = fixture(:user)
  #   conn = delete conn, user_path(conn, :delete, user)
  #   assert response(conn, 200)
  #   # assert_error_sent 404, fn ->
  #   #   get conn, user_path(conn, :show, user)
  #   # end
  # end
end
