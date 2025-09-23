import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :housekeeping_book, HousekeepingBook.Repo,
  username: System.get_env("TEST_DB_USER", "postgres"),
  password: System.get_env("TEST_DB_PASSWORD", "postgres"),
  hostname: System.get_env("TEST_DB_HOST", "localhost"),
  database: "housekeeping_book_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
# Generate a new secret with: mix phx.gen.secret
# Or use environment variable: System.get_env("TEST_SECRET_KEY_BASE")
secret_key_base = "p6Es8iDsm6lteeic8h9fw7IhOmsSYzz0WIvgfyAz3pGQO8UmUf2NLYPSc7Fv59YY"

config :housekeeping_book, HousekeepingBookWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  https: [port: 4001],
  secret_key_base: secret_key_base,
  server: false

config :housekeeping_book, :accounts, signing_secret: secret_key_base
# In test we don't send emails.
config :housekeeping_book, HousekeepingBook.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :housekeeping_book, :secret_code, ""

config :ash, :disable_async?, true
config :ash, :missed_notifications, :ignore
