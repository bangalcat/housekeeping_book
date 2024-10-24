defmodule HousekeepingBookWeb.Router do
  use HousekeepingBookWeb, :router

  use AshAuthentication.Phoenix.Router

  import HousekeepingBookWeb.UserAuth
  import HousekeepingBookWeb.UserAgent
  import PhoenixStorybook.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HousekeepingBookWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_user_device
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", HousekeepingBookWeb do
    pipe_through :browser

    get "/", PageController, :home
    auth_routes AuthController, HousekeepingBook.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{HousekeepingBookWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    HousekeepingBookWeb.AuthOverrides,
                    AshAuthentication.Phoenix.Overrides.Default
                  ],
                  layout: {HousekeepingBookWeb.Layouts, :app}
  end

  scope "/", HousekeepingBookWeb do
    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {HousekeepingBookWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {HousekeepingBookWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {HousekeepingBookWeb.LiveUserAuth, :live_no_user}
    end
  end

  scope "/" do
    storybook_assets()
  end

  # Other scopes may use custom stacks.
  # scope "/api", HousekeepingBookWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:housekeeping_book, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HousekeepingBookWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    scope "/", HousekeepingBookWeb do
      pipe_through :browser

      live_storybook("/storybook", backend_module: HousekeepingBookWeb.Storybook)
    end
  end

  ## Authentication routes

  scope "/", HousekeepingBookWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{HousekeepingBookWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", HousekeepingBookWeb do
    pipe_through [:browser, :require_authenticated_user]

    ash_authentication_live_session :require_authenticated_user,
      on_mount: [{HousekeepingBookWeb.LiveUserAuth, :live_user_required}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/records", RecordLive.Index, :index
      live "/records/new", RecordLive.Index, :new
      live "/records/:id/edit", RecordLive.Index, :edit

      live "/monthly/records", RecordLive.Monthly, :index
      live "/monthly/records/:year/:month", RecordLive.Monthly, :index
      live "/monthly/records/:year/:month/new", RecordLive.Monthly, :new
      live "/monthly/records/:year/:month/:id/edit", RecordLive.Monthly, :edit

      live "/records/:id", RecordLive.Show, :show
      live "/records/:id/show/edit", RecordLive.Show, :edit

      live "/categories", CategoryLive.Index, :index
      live "/categories/new", CategoryLive.Index, :new
      live "/categories/:id/edit", CategoryLive.Index, :edit

      live "/categories/:id", CategoryLive.Show, :show
      live "/categories/:id/show/edit", CategoryLive.Show, :edit

      live "/tags", TagLive.Index, :index
      live "/tags/new", TagLive.Index, :new
      live "/tags/:id/edit", TagLive.Index, :edit

      live "/tags/:id", TagLive.Show, :show
      live "/tags/:id/show/edit", TagLive.Show, :edit
    end
  end

  scope "/", HousekeepingBookWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    ash_authentication_live_session :current_user,
      on_mount: [{HousekeepingBookWeb.LiveUserAuth, :live_user_optional}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/admin", HousekeepingBookWeb do
    pipe_through [:browser, :require_authenticated_user]

    ash_authentication_live_session :admin_require_authenticated_user,
      on_mount: [{HousekeepingBookWeb.LiveUserAuth, :live_user_required}] do
      live "/users", UserLive.Index, :index
      live "/users/new", UserLive.Index, :new
      live "/users/:id/edit", UserLive.Index, :edit

      live "/users/:id", UserLive.Show, :show
      live "/users/:id/show/edit", UserLive.Show, :edit
    end
  end
end
