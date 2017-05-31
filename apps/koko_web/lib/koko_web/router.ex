defmodule Koko.Web.Router do
  use Koko.Web, :router
  # use Plug.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Koko.Web do
    pipe_through :api
    resources "/documents", DocumentController
    resources "/users", UserController, except: [:edit]
    resources "/authentication", AuthenticationController

    get "/public/documents", DocumentController, :index_public
    get "/public/documents/:id", DocumentController, :show_public
  end

  

end
