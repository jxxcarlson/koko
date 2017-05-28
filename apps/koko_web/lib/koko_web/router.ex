defmodule Koko.Web.Router do
  use Koko.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Koko.Web do
    pipe_through :api
    resources "/documents", DocumentController
    resources "/users", UserController, except: [:edit]
    resources "/authentication", AuthenticationController
  end
end
