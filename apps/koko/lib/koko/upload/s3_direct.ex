defmodule  Koko.Upload.S3Direct do

  alias Koko.User.Signature

  @expiration Application.get_env(:s3_direct_upload, :expiration_api, S3DirectUpload.Expiration)

  @moduledoc """

  Pre-signed S3 upload helper for client-side multipart POSTs.

  See: [Browser Uploads to S3 using HTML POST Forms](https://aws.amazon.com/articles/1434/)

  This module expects three application configuration settings for the
  AWS access and secret keys and the S3 bucket name. Here is an
  example configuration that reads these from environment
  variables. Add your own configuration to `config.exs`.

  ```
  config :s3_direct_upload,
    aws_access_key: System.get_env("AWS_ACCESS_KEY_ID"),
    aws_secret_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
    aws_s3_bucket: System.get_env("AWS_S3_BUCKET")

  ```

  """

  @doc """

  The `S3DirectUpload` struct represents the data necessary to
  generate an S3 pre-signed upload object.

  The required fields are:

  - `file_name` the name of the file being uploaded
  - `mimetype` the mimetype of the file being uploaded
  - `path` the path where the file will be uploaded in the bucket

  Fields that can be over-ridden are:

  - `acl` defaults to `public-read`
  - `access_key` the AWS access key, defaults to application settings
  - `secret_key` the AWS secret key, defaults to application settings
  - `bucket` the S3 bucket, defaults to application settings

  """
  defstruct file_name: nil, mimetype: nil, path: nil,
    acl: "public-read",
    access_key: Application.get_env(:s3_direct_upload, :aws_access_key),
    secret_key: Application.get_env(:s3_direct_upload, :aws_secret_key),
    bucket: Application.get_env(:s3_direct_upload, :aws_s3_bucket)

  def presigned(%S3DirectUpload{} = upload) do
      date = Koko.User.Utils.iso_8601_now   # utc_now()
      %{
        url: "https://#{upload.bucket}.s3.amazonaws.com",
        credentials: %{
          AWSAccessKeyId: upload.access_key,
          signature: Signature.generate_v4(upload, policy(upload)),
          policy: policy(upload),
          acl: upload.acl,
          key: "#{upload.path}/#{upload.file_name}",
          date: date,
          credential: "#{upload.access_key}/#{date}/us-east-1/s3/aws4_request"
        }
      }
  end

  # REFERENCE: http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTCon.html
  defp policy(upload) do
    %{
      expiration: @expiration.datetime,
      conditions: conditions(upload)
    }
    |> Poison.encode!
    |> Base.encode64
  end

  defp conditions(upload) do
    [
      %{"bucket" => upload.bucket},
      %{"acl" => upload.acl},
      ["starts-with", "$Content-Type", upload.mimetype],
      ["starts-with", "$key", upload.path]
    ]
  end

  end
