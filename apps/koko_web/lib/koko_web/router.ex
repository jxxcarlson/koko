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
    resources "/users", UserController, except: [:edit, :delete]
    resources "/authentication", AuthenticationController

    put "/users/saveuserstate/:id", UserController, :saveuserstate
    get "/users/getuserstate/:id", UserController, :getuserstate

    get "/public/documents", PublicDocumentController, :index
    get "/public/documents/:id", PublicDocumentController, :show

    get "/hello", StatusController, :hello
    get "/credentials", CredentialsController, :presigned
  end

  scope "/archive", Koko.Web do
    pipe_through :browser
    get "/versions/:id", ArchiveController, :index
    get "/version/:id", ArchiveController, :show
    get "/new_repository/:user_id/:name", ArchiveController, :new_repository
    get "/new_version/:doc_id", ArchiveController, :new_version
  end

  scope "/print", Koko.Web do
    pipe_through :browser
    get "/documents/:id", PrintController, :show
  end

  scope "/export", Koko.Web do
    pipe_through :browser
    get "/documents/:id", ExportController, :show
  end

  scope "/imagecatalogue", Koko.Web do
    pipe_through :browser
    get "/documents/:id", ImageCatalogueController, :show
  end



end
