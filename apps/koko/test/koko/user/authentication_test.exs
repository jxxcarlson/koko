defmodule Koko.AuthenticationTest do
  use Koko.DataCase

  alias Koko.User.User
  alias Koko.User.Authentication


  # setup_all do
  #   # Explicitly get a connection before each test
  #   # By default the test is wrapped in a transaction
  #   :ok = Ecto.Adapters.SQL.Sandbox.checkout(Koko.Repo)
  #
  #   # The :shared mode allows a process to share
  #   # its connection with any other process automatically
  #   Ecto.Adapters.SQL.Sandbox.mode(Koko.Repo, { :shared, self() })
  #
  #   :ok
  # end




  describe "users" do

    @valid_user_attrs %{"admin" => true, "blurb" => "BLURB!", "email" => "yada@foo.io",
      "name" => "Yada T. Urdik", "username" => "yada", "password" => "abc.617.ioj"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_user_attrs)
        |> Authentication.create_user()
      user
    end

    @update_attrs %{"admin" => false, "blurb" => "whatever", "email" => "yada@foo.io", "name" => "Yadem V. Aafik", "password_hash" => "s7^%g$l-9+", "username" => "aday"}
    @invalid_attrs %{"admin" => nil, "blurb" => nil, "email" =>  nil, "name" => nil, "password_hash" =>  nil, "username" => nil}

    test "list_users/0 returns all users" do
      n = Authentication.list_users("") |> length
      user = user_fixture()
      assert user.email == "yada@foo.io"
      assert (Authentication.list_users("") |> length) == n + 1
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      found_user = Authentication.get_user!(user.id)
      assert found_user.email == user.email
      assert found_user.username == user.username
    end

    test "create_user/1 with valid data creates a user" do
      {:ok, %User{} = user} = Authentication.create_user(@valid_user_attrs)
      assert user.admin == true
      assert user.blurb == "BLURB!"
      assert user.email == "yada@foo.io"
      assert user.name == "Yada T. Urdik"
      assert (user.password_hash |> String.length) == 60
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
      assert user.blurb == "whatever"
      assert user.email == "yada@foo.io"
      assert user.name == "Yadem V. Aafik"
      assert user.password_hash == "s7^%g$l-9+"
      assert user.username == "aday"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Authentication.update_user(user, @invalid_attrs)
      # assert user == Authentication.get_user!(user.id)
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

  #   # user = user_fixture(%{})
   #
  #   # sIO.puts "HHH user.id = #{user.id}"
   #
  #   @valid_attrs %{"email" => "yada@foo.io", "password" => "abc.617.ioj"}
  #   # @invalid_attrs %{}
   #
  #   # @valid_attrs %{token: "some token"}
  #   @invalid_attrs %{"email" => "yada@foo.io", "password" => "abc.617.ioj999"}
   #
  #   u_attr = %{"admin" => true, "blurb" => "BLURB!", "email" => "yada@foo.io",
  #     "name" => "Yada T. Urdik", "username" => "yada", "password" => "abc.617.ioj"}
   #
  #  Authentication.create_user (u_attr)
   #
  #   test "create_session/1 with valid data creates a session" do
  #     {:ok, token} = Authentication.create_session(@valid_attrs)
  #     assert (token |> String.split(".") |> length) == 3
  #   end
   #
  #   test "create_session/1 with invalid data returns error changeset" do
  #     {:error, _} = Authentication.create_session(@invalid_attrs)
  #     # assert message =  "user id is nil"
  #   end


  end
end
