defmodule Koko.AuthenticationTest do
  use Koko.DataCase

  alias Koko.Authentication

  describe "users" do
    alias Koko.Authentication.User

    @valid_attrs %{admin: true, blurb: "some blurb", email: "yada@foo.io", name: "Yada T. Urdik", password_hash: "some password_hash", username: "yada"}
    @update_attrs %{admin: false, blurb: "some updated blurb", email: "some updated email", name: "some updated name", password_hash: "some updated password_hash", username: "some updated username"}
    @invalid_attrs %{admin: nil, blurb: nil, email: nil, name: nil, password_hash: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Authentication.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Authentication.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Authentication.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Authentication.create_user(@valid_attrs)
      assert user.admin == true
      assert user.blurb == "some blurb"
      assert user.email == "yada@foo.io"
      assert user.name == "Yada T. Urdik"
      assert user.password_hash == "some password_hash"
      assert user.username == "yada"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Authentication.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Authentication.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.admin == false
      assert user.blurb == "some updated blurb"
      assert user.email == "some updated email"
      assert user.name == "some updated name"
      assert user.password_hash == "some updated password_hash"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Authentication.update_user(user, @invalid_attrs)
      assert user == Authentication.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Authentication.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Authentication.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Authentication.change_user(user)
    end
  end

  describe "sessions" do
    alias Koko.Authentication.Session

   # user = user_fixture()
    @valid_attrs %{user_id: 22, username: "jfoo", token: "abc123"}
    # @invalid_attrs %{}

    # @valid_attrs %{token: "some token"}
    @invalid_attrs %{token: nil, user_id: nil, username: nil}

    def session_fixture(attrs \\ %{}) do
      {:ok, session} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Authentication.create_session()

      session
    end


    test "list_sessions/0 returns all sessions" do
      session = session_fixture(@valid_attrs)
      assert Authentication.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Authentication.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      {:ok, session} = Authentication.create_session(@valid_attrs)
      assert (session.token |> String.split(".") |> length) == 3
    end

    test "create_session/1 with invalid data returns error changeset" do
      {:error, _} = Authentication.create_session(@invalid_attrs)
      # assert message =  "user id is nil"
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Authentication.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Authentication.get_session!(session.id) end
    end

  end
end
