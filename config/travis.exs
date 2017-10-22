use Mix.Config

defmodule Ownership do
  def timeout do
    try do
      String.to_integer(System.get_env("DB_TIMEOUT"))
    rescue
      ArgumentError -> 25_000
    end
  end
end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :open_pantry, OpenPantry.Web.Endpoint,
  http: [port: 4001],
  server: true

config :open_pantry, :sql_sandbox, true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :open_pantry, OpenPantry.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: OpenPantry.PostgresTypes,
  username: "postgres",
  password: "",
  database: "open_pantry_test",
  hostname: "localhost",
  ownership_timeout: Ownership.timeout,
  pool: Ecto.Adapters.SQL.Sandbox

config :open_pantry, :admin_authentication, OpenPantry.ZeroAuth

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "OpenPantry",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "I am not a very secret key",
  serializer: OpenPantry.GuardianSerializer

config :wallaby,
  driver: Wallaby.Experimental.Chrome,
  max_wait_time: 5_000,
  screenshot_on_failure: true,
  js_errors: true,
  js_logger: :stdio
