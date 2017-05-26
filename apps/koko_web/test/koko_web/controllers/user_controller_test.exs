defmodule Koko.Web.UserControllerTest do
  use Koko.Web.ConnCase

  alias Koko.Authentication
  alias Koko.Authentication.User

  @create_attrs %{admin: true, blurb: "some blurb", email: "some email", name: "some name", password_hash: "some password_hash", username: "some username"}
  @update_attrs %{admin: false, blurb: "some updated blurb", email: "some updated email", name: "some updated name", password_hash: "some updated password_hash", username: "some updated username"}
  @invalid_attrs %{admin: nil, blurb: nil, email: nil, name: nil, password_hash: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Authentication.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates user and renders user when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, user_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "admin" => true,
      "blurb" => "some blurb",
      "email" => "some email",
      "name" => "some name",
      "password_hash" => "some password_hash",
      "username" => "some username"}
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen user and renders user when data is valid", %{conn: conn} do
    %User{id: id} = user = fixture(:user)
    conn = put conn, user_path(conn, :update, user), user: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, user_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "admin" => false,
      "blurb" => "some updated blurb",
      "email" => "some updated email",
      "name" => "some updated name",
      "password_hash" => "some updated password_hash",
      "username" => "some updated username"}
  end

  test "does not update chosen user and renders errors when data is invalid", %{conn: conn} do
    user = fixture(:user)
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen user", %{conn: conn} do
    user = fixture(:user)
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, user)
    end
  end
end
