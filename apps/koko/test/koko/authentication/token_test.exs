defmodule Koko.Authentication.TokenTest do
  use Koko.DataCase

  alias Koko.Authentication.Token

  describe "token" do

    test "generate token with vaid attributes" do
      {:ok, token} = Token.get(1, "joe")

      assert token |> String.split(".") |> length == 3
    end



    test "a valid token is recognized as such" do
       {:ok, token} = Token.get(1, "joe")
       assert Token.authenticated(token) == true
    end


    test "an invalid token is rejected" do
       token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ0.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImpvZSJ0.yMEnTxaqJwAc3Q5bU9sBAtbMtDk3dugiNj7PQ23cHT0"
       assert Token.authenticated(token) == false
    end

  end

end
