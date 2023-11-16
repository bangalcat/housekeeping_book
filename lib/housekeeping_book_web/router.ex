defmodule HousekeepingBookWeb.Router do
  use HousekeepingBookWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HousekeepingBookWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HousekeepingBookWeb do
    pipe_through :browser

    get "/", PageController, :home
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
  end
end
