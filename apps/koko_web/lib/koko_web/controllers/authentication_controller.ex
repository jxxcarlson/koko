defmodule Koko.Web.AuthenticationController do
  use Koko.Web, :controller
  import Plug.Conn

  alias Koko.User.Authentication

  # plug :scrub_params, "user" when action in [:create]
  # plug :actionP

  action_fallback Koko.Web.FallbackController


  def create(conn, %{"authenticate" => payload}) do
    params = Koko.Utility.project2map(payload)
    with {:ok, token, _} <- Authentication.get_token(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", authentication_path(conn, :show, "headquarters"))
      |> render("show.json", token: token)
    else
      _ -> conn |> render("error.json", error: "Incorrect email or password")
    end
  end

end
