defmodule Koko.Web.SessionControllerTest do
  use Koko.Web.ConnCase

  alias Koko.Authentication

  @create_attrs %{"email" => "yada@foo.io", "password" => "abc.123"}
  @bad_credential_attrs %{"email" => "yada@foo.io", "password" => "abc.111"}
  @invalid_attrs %{"email" => nil, "password" => nil}

  def fixture(:session) do
    {:ok, session} = Authentication.create_session(@create_attrs)
    session
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, session_path(conn, :index)
    assert json_response(conn, 200)["sessions"] == []
  end

  test "creates session and renders session when data is valid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["session"]

    conn = get conn, session_path(conn, :show, id)
    %{"token" => token} = json_response(conn, 200)["session"]
    assert (token |> String.split(".") |> length ) == 3
  end

  test "does not create session and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end


  test "deletes chosen session", %{conn: conn} do
    session = fixture(:session)
    conn = delete conn, session_path(conn, :delete, session)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, session_path(conn, :show, session)
    end
  end
end
