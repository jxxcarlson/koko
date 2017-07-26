defmodule Koko.Web.Router do
  use Koko.Web, :router
  # use Plug.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
   plug :accepts, ["html"]
   plug :fetch_session
   plug :fetch_flash
   plug :protect_from_forgery
   plug :put_secure_browser_headers
 end

  scope "/api", Koko.Web do
    pipe_through :api
    resources "/documents", DocumentController
    resources "/users", UserController, except: [:edit]
    resources "/authentication", AuthenticationController

    get "/public/documents", DocumentController, :index_public
    get "/public/documents/:id", DocumentController, :show_public

    get "/hello", StatusController, :hello
    get "/credentials", CredentialsController, :presigned
  end

  scope "/print", Koko.Web do
    pipe_through :browser
    get "/documents/:id", PrintController, :show
  end



end
