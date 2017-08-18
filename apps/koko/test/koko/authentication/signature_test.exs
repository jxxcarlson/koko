defmodule AuthTest do
  use ExUnit.Case

  alias Auth.Signature

  # NOTE: The code is Auth.Signature is lightly adapted from
  # https://github.com/CargoSense/ex_aws/ (@copyright CargoSense, MIT License)

  # REFERENCES:
  #
  #    http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-authentication-HTTPPOST.html
  #    http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-post-example.html
  #

  @awsSecretAccessKey "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  @region "us-east-1"

  # AWSAccessKeyId	AKIAIOSFODNN7EXAMPLE
  # x-amz-date in the policy (20151229)

  @string_to_sign "eyAiZXhwaXJhdGlvbiI6ICIyMDE1LTEyLTMwVDEyOjAwOjAwLjAwMFoiLA0KICAiY29uZGl0aW9ucyI6IFsNCiAgICB7ImJ1Y2tldCI6ICJzaWd2NGV4YW1wbGVidWNrZXQifSwNCiAgICBbInN0YXJ0cy13aXRoIiwgIiRrZXkiLCAidXNlci91c2VyMS8iXSwNCiAgICB7ImFjbCI6ICJwdWJsaWMtcmVhZCJ9LA0KICAgIHsic3VjY2Vzc19hY3Rpb25fcmVkaXJlY3QiOiAiaHR0cDovL3NpZ3Y0ZXhhbXBsZWJ1Y2tldC5zMy5hbWF6b25hd3MuY29tL3N1Y2Nlc3NmdWxfdXBsb2FkLmh0bWwifSwNCiAgICBbInN0YXJ0cy13aXRoIiwgIiRDb250ZW50LVR5cGUiLCAiaW1hZ2UvIl0sDQogICAgeyJ4LWFtei1tZXRhLXV1aWQiOiAiMTQzNjUxMjM2NTEyNzQifSwNCiAgICB7IngtYW16LXNlcnZlci1zaWRlLWVuY3J5cHRpb24iOiAiQUVTMjU2In0sDQogICAgWyJzdGFydHMtd2l0aCIsICIkeC1hbXotbWV0YS10YWciLCAiIl0sDQoNCiAgICB7IngtYW16LWNyZWRlbnRpYWwiOiAiQUtJQUlPU0ZPRE5ON0VYQU1QTEUvMjAxNTEyMjkvdXMtZWFzdC0xL3MzL2F3czRfcmVxdWVzdCJ9LA0KICAgIHsieC1hbXotYWxnb3JpdGhtIjogIkFXUzQtSE1BQy1TSEEyNTYifSwNCiAgICB7IngtYW16LWRhdGUiOiAiMjAxNTEyMjlUMDAwMDAwWiIgfQ0KICBdDQp9"

  def test_config do
    %{
      secret_access_key: @awsSecretAccessKey,
      region: @region
    }
  end

  # datetime = {{2013, 5, 24}, {0, 0, 0}}
  # 20151229T000000Z"


  test "signing key" do

    signing_key = Signature.signing_key("s3", {{2015, 12, 29}, {0, 0, 0}}, test_config())

    {:ok, signing_key_from_sigaws} = Sigaws.Util.signing_key(
        {2015, 12, 29} |> Date.from_erl!(),
        @region,
        "s3",
        @awsSecretAccessKey
      )

    assert signing_key == signing_key_from_sigaws

  end

  test "signature" do

    signature = Signature.generate_signature_v4("s3", test_config(), {{2015, 12, 29}, {0, 0, 0}}, @string_to_sign)

    {:ok, signing_key_from_sigaws} = Sigaws.Util.signing_key(
        {2015, 12, 29} |> Date.from_erl!(),
        @region,
        "s3",
        @awsSecretAccessKey
      )

    signature_from_sigaws = signing_key_from_sigaws
      |>  Sigaws.Util.hmac([@string_to_sign])
      |>  Base.encode16(case: :lower)

    assert signature == signature_from_sigaws
  end

end
