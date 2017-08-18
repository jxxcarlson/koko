defmodule Koko.Authentication.Signature do

  import Koko.Authentication.Utils, only: [hmac_sha256: 2, date: 1, bytes_to_hex: 1, utc_now: 1]


  def config(secret_access_key, region) do
    %{
      secret_access_key: secret_access_key,
      region: region
    }
  end

  # Test:
  #
  # iex(1)> alias Koko.Authentication.Signature
  # Koko.Authentication.Signature
  # iex(2)> alias Koko.Authentication.Utils
  # Koko.Authentication.Utils
  # iex(3)> cf = Signature.config("abc", "us-east-1")
  # %{region: "us-east-1", secret_access_key: "abc"}
  # iex(4)> str = "abc"
  # "abc"
  # iex(5)> Signature.generate_signature_v4("s3", cf, Utils.utc_now(:tuple), str)
  # "ca365c6566d2b0553c351053a18514ee09e746e872b80fc59f9b7dc295b79baf"
  #

  def generate_v4(config, string_to_sign) do
    generate_v4("s3", config, utc_now(:tuple), string_to_sign)
  end

  def generate_v4(service, config, datetime, string_to_sign) do
    service
    |> signing_key(datetime, config)
    |> hmac_sha256(string_to_sign)
    |> bytes_to_hex
  end

  def signing_key(service, datetime, config) do
    ["AWS4", config[:secret_access_key]]
    |> hmac_sha256(date(datetime))
    |> hmac_sha256(config[:region])
    |> hmac_sha256(service)
    |> hmac_sha256("aws4_request")
  end

end
