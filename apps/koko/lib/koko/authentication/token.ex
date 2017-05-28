defmodule Koko.Authentication.Token do

  @moduledoc """
  This module carries the functions used to generate tokens,
  determine whether they are valid, and inspec the token payload.
  """

    import Joken


    @doc """
    Return a signed token with payload %{user_id: USER_ID, username: USERNAME.
    NOTE: the payload is NOT encrypted and so can be read by anyone
    """
    def get(user_id, username) do
      secret = System.get_env("KOKO_SECRET")
      cond do
        user_id == nil -> {:error, 400}
        username == nil -> {:error, 400}
        true ->
          %{"user_id" => user_id, "username" => username}
          |> token
          |> with_validation("user_id", &(&1 == user_id))
          |> with_signer(hs256(secret))
          |> sign
          |> get_compact
          |> (fn token -> {:ok, token} end).()
      end
    end


    defp validate(tok, user_id) do
      secret = System.get_env("KOKO_SECRET")
      tok
      |> token
      |> with_validation("user_id", &(&1 == user_id))
      |> with_signer(hs256(secret))
      |> verify
    end

    defp validate(tok) do
      secret = System.get_env("KOKO_SECRET")
      tok
      |> token
      |> with_signer(hs256(secret))
      |> verify
    end

    @doc """
    Return true iff the token signature is valid and the token's signed user_id
    is the same as user_id.
    """
    def authenticated(token, user_id) do
      validate(token, user_id).error == nil
    end

    @doc """
    Return true iff the token signature is valid.
    """
    def authenticated(token) do
      validate(token).error == nil
    end

    defp decode2string(token) do
      token
      |> String.split(".")
      |> Enum.at(1)
      |> Base.decode64(padding: false)
    end

    @doc """
    payload("aaa.bbb.ccc) == {{:ok, %{"user_id" => 2, "username" => "yada"}}
    in the case that the payload segment is valid. Here "valid" means a
    correctly base64-encoded representation of a struct.  NOTE that the payload
    is not encrypted and can be read by anyone.

    payload("aaa.bbb.ccc) == {:error, "Could not decode payload"} in the
    invalid case.
    """
    def payload(token) do
      with {:ok, str} <- decode2string(token),
           {:ok, json} <- Poison.Parser.parse str
      do
        {:ok, json}
      else
        err -> {:error, "Could not decode payload"}
      end
    end

end
