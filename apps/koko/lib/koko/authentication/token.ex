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
    def get(user_id, username, seconds_from_now \\ -1) do
      t = if (seconds_from_now < 0) do
        System.get_env("KOKO_EXPIRATION") |> String.to_integer
      else
        seconds_from_now
      end
      secret = System.get_env("KOKO_SECRET")
      cond do
        user_id == nil -> {:error, 400}
        username == nil -> {:error, 400}
        true ->
          %{"user_id" => user_id, "username" => username,
             "exp" => expiration_time(t)}
          |> token
          |> with_validation("user_id", &(&1 == user_id))
          |> with_signer(hs256(secret))
          |> sign
          |> get_compact
          |> (fn token -> {:ok, token} end).()
      end
    end

    def expiration_time(seconds_from_now) do
      now = DateTime.utc_now() |> DateTime.to_unix()
      now + seconds_from_now
    end

    def validate(tok, user_id) do
      secret = System.get_env("KOKO_SECRET")
      tok
      |> token
      |> with_validation("user_id", &(&1 == user_id))
      |> with_signer(hs256(secret))
      |> verify
    end

    def validate(tok) do
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
      vt = validate(token, user_id)
      signature_valid = vt.error == nil
      now = DateTime.utc_now() |> DateTime.to_unix()
      expired = vt.claims["exp"] <= now
      signature_valid && not expired
    end

    @doc """
    Return true iff the token signature is valid.
    """
    def authenticated(token) do
      vt = validate(token)
      signature_valid = vt.error == nil
      now = DateTime.utc_now() |> DateTime.to_unix()
      expired = vt.claims["exp"] <= now
      signature_valid && not expired
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
