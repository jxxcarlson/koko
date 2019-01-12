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

    put "/share/:id/:username/:action", DocumentController, :share

    put "/users/saveuserstate/:id", UserController, :saveuserstate
    get "/users/getuserstate/:id", UserController, :getuserstate
    post "/users/increment_media_count/:id", UserController, :increment_media_count
    get "/verify/:token", UserController, :verify
    get "/request_verification", UserController, :request_verification
    get "/send_verification_email", UserController, :send_verification_email


    get "/public/documents", PublicDocumentController, :index
    get "/public/documents/:id", PublicDocumentController, :show

    get "/hello", StatusController, :hello
    get "/credentials", CredentialsController, :credentials
    get "/presigned", CredentialsController, :presigned

    post "/mail", MailController, :mail

    get "/password/request", PasswordController, :show_request_form
    get "/password/mail_reset_link", PasswordController, :mail_reset_link
    get "/password/form", PasswordController, :show_reset_form
    get "/password/reset", PasswordController, :reset_password

    get "/export/:id", ExportToJsonController, :show
    get "/image_list/:id", ExportToJsonController, :image_list
    post "/image", ImageController, :create
    get  "/images", ImageController, :index

    post "/print/pdf/:filename", PrintController, :process
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
    get "pdf/:filename", PrintController, :display_pdf_file
    get "/documents/:id", PrintController, :show
  end

  scope "/export", Koko.Web do
    pipe_through :browser
    get "/documents/:id", ExportController, :show
    get "/json/:id", ExportController, :export_latex_to_json
  end

  scope "/imagecatalogue", Koko.Web do
    pipe_through :browser
    get "/documents/:id", ImageCatalogueController, :show
  end



end
