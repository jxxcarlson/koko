defmodule Koko.Authentication.Credentials do

  def signing_key(region, secret_access_key) do
    {:ok, signing_key_from_sigaws} = Sigaws.Util.signing_key(
        {2015, 12, 29} |> Date.from_erl!(),
        region,
        "s3",
        secret_access_key
      )
  end

end
