use Mix.Config

# Configure your database
config :koko, Koko.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "koko_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
