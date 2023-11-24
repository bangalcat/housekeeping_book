defmodule HousekeepingBookWeb.Router do
  use HousekeepingBookWeb, :router

  import HousekeepingBookWeb.UserAuth
  import PhoenixStorybook.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HousekeepingBookWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HousekeepingBookWeb do
    pipe_through :browser

    get "/", PageController, :home
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

    live_session :require_authenticated_user,
      on_mount: [{HousekeepingBookWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/records", RecordLive.Index, :index
      live "/records/new", RecordLive.Index, :new
      live "/records/:id/edit", RecordLive.Index, :edit

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

    live_session :current_user,
      on_mount: [{HousekeepingBookWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/admin", HousekeepingBookWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admin_require_authenticated_user,
      on_mount: [{HousekeepingBookWeb.UserAuth, :ensure_authenticated}] do
      live "/users", UserLive.Index, :index
      live "/users/new", UserLive.Index, :new
      live "/users/:id/edit", UserLive.Index, :edit

      live "/users/:id", UserLive.Show, :show
      live "/users/:id/show/edit", UserLive.Show, :edit
    end
  end
end
