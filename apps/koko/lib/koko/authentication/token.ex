defmodule Koko.Authentication.Token do

    import Joken


    @doc """
    Return a token with signed user_id and username
    """
    def get(user_id, username) do
      cond do
        user_id == nil -> {:error, "user id is nil"}
        username == nil -> {:error, "username is nil"}
        true ->
          %{"user_id" => user_id, "username" => username}
          |> token
          #|> with_validation("user_id", &(&1 == user_id))
          #|> with_validation("username", &(&1 == username))
          |> with_signer(hs256("yumpa80937173mU,@izq0#$mcq^&!HFQlkdfjonvueo,-+"))
          |> sign
          |> get_compact
          |> (fn token -> {:ok, token} end).()
      end

    end

    @doc """
    Check to see that the token's signed user_id
    is the same as user_id.
    """
    defp validate(tok, user_id) do
      tok
      |> token
      |> with_validation("user_id", &(&1 == user_id))
      |> with_signer(hs256("yumpa80937173mU,@izq0#$mcq^&!HFQlkdfjonvueo,-+"))
      |> verify
    end

    def validate(tok) do
      tok
      |> token
      |> with_signer(hs256("yumpa80937173mU,@izq0#$mcq^&!HFQlkdfjonvueo,-+"))
      |> verify
    end

    @doc """
    Return true iff the token's signed user_id
    is the same as user_id.
    """
    def authenticated(token, user_id) do
      result = Koko.Authentication.Token.validate(token, user_id)
      result.error == nil
    end

    def authenticated(token) do
      result = Koko.Authentication.Token.validate(token)
      result.error == nil
    end

end
