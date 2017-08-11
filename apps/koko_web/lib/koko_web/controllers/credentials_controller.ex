defmodule Koko.Web.CredentialsController do
  use Koko.Web, :controller

  alias Koko.Authentication.Token
  # alias Koko.Authentication

  def get_header(conn, name) do
     result = Plug.Conn.get_req_header(conn, name)
     case result do
         [] -> {:error, "No #{name} header"}
         _ -> {:ok, result}
     end
  end

  def send_credentials(conn) do
    IO.puts "--------- HEADER ----------"
    IO.inspect get_header(conn, "authorization")
    IO.puts "--------------------"
    p = conn.params
    credentials = %S3DirectUpload{
        file_name: p["filename"],
        mimetype: p["mimetype"],
        path: p["path"]}
    |> S3DirectUpload.presigned
    render(conn, "credentials.json", credentials: credentials)
  end

  def send_error(conn) do
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
