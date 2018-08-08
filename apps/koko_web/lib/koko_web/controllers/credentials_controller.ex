defmodule Koko.Web.CredentialsController do
  use Koko.Web, :controller

  # alias Koko.Web.CredentialsView
  alias Koko.User.Token
  # alias Koko.Authentication

  def get_header(conn, name) do
     result = Plug.Conn.get_req_header(conn, name)
     case result do
         [] -> {:error, "No #{name} header"}
         _ -> {:ok, result}
     end
  end

  def send_credentials(conn) do
    # IO.inspect get_header(conn, "authorization"), label: "HEADERS"
    p = conn.params
    # IO.inspect p, label: "conn.params"
    path = p["path"]
    filename = p["filename"]
    mimetype = p["mimetype"]
    path = p["path"]

    # upload = %S3DirectUpload{file_name: filename, mimetype: mimetype, path: "/jxx"}
    # IO.inspect(upload, label: "UPLOAD !!!")
    # IO.puts "upload.acl = #{upload.acl}"
    # credentials = upload |> S3DirectUpload.presigned

    credentials = %S3DirectUpload{file_name: filename, mimetype: mimetype, path: path, acl: "public-read"}
      |> S3DirectUpload.presigned
    # IO.inspect(credentials, label: "CREDENTIALS !!!")
    render(conn, "credentials.json", credentials: credentials)
  end

  # ExAws.Config.new(:s3) |> ExAws.S3.presigned_url(:put, "noteimages", "foo.jpg")
  def send_presigned_url(conn) do
    # IO.inspect get_header(conn, "authorization"), label: "HEADERS"
    p = conn.params
    # IO.inspect p, label: "conn.params"
    path = p["path"]
    bucket = p["bucket"]
    {:ok, presigned_url} = ExAws.Config.new(:s3) |> ExAws.S3.presigned_url(:put, bucket, path)
    render(conn, "presigned.json", url: presigned_url)
  end

  def send_error(conn) do
    IO.puts "Error authenticating token"
    render(conn, "error.json", error: "authorization failure")
  end
    

  # TEST URL: http://localhost:4000/api/credentials?filename=foo.jpg&mimetype=image/jpeg&bucket=noteimages&path=bar
  # TEST HEADER: %{"authorization": "Bearer abc... uvwxy"}
  def credentials(conn, _) do
      auth = Token.authenticated_from_header(conn)
      # IO.inspect auth, label: "AUTH!!!"
      case auth do
        {:ok, true} -> send_credentials(conn)
        {:ok, false} -> send_error(conn)
      end
  end

  # TEST URL: http://localhost:4000/api/credentials?filename=foo.jpg&mimetype=image/jpeg&bucket=noteimages&path=bar
  # TEST HEADER: %{"authorization": "Bearer abc... uvwxy"}
  def presigned(conn, _) do
    auth = Token.authenticated_from_header(conn)
    # IO.inspect auth, label: "AUTH!!!"
    case auth do
      {:ok, true} -> send_presigned_url(conn)
      {:ok, false} -> send_error(conn)
    end
end

end
