defmodule Koko.Web.CredentialsController do
  use Koko.Web, :controller

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
    IO.inspect get_header(conn, "authorization"), label: "HEADERS"
    p = conn.params
    IO.inspect p, label: "conn.params"
    path = p["path"]
    filename = p["filename"]
    mimetype = p["mimetype"]

    upload = %S3DirectUpload{file_name: filename, mimetype: mimetype, path: "/jxx", region: "us-east-1"}
    credentials = S3DirectUpload.presigned upload
    IO.inspect(credentials, label: "CREDENTIALS @ CONTROLLER")
    render(conn, "credentials.json", credentials: credentials)
  end

  def send_error(conn) do
    IO.puts "Error authenticating token"
    render(conn, "error.json", error: "authorization failure")
  end


  # TEST URL: http://localhost:4000/api/credentials?filename=foo.jpg&mimetype=image/jpeg&bucket=noteimages&path=bar
  # TEST HEADER: %{"authorization": "Bearer abc... uvwxy"}
  def presigned(conn, _) do
      auth = Token.authenticated_from_header(conn)
      case auth do
        {:ok, true} -> send_credentials(conn)
        {:ok, false} -> send_error(conn)
      end
  end


end
