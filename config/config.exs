# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :housekeeping_book,
  ecto_repos: [HousekeepingBook.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :housekeeping_book, HousekeepingBookWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: HousekeepingBookWeb.ErrorHTML, json: HousekeepingBookWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: HousekeepingBook.PubSub,
  live_view: [signing_salt: "v974NCAa"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :housekeeping_book, HousekeepingBook.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :flop, :repo, HousekeepingBook.Repo

config :flop_phoenix,
  pagination: [opts: {HousekeepingBookWeb.CustomComponents, :pagination_opts}],
  table: [opts: {HousekeepingBookWeb.CustomComponents, :table_opts}]

config :housekeeping_book, :mailer, mailer_sender: "contact@example.com"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
