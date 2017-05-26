use Mix.Config

# Configure your database
config :koko, Koko.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "koko_dev",
  hostname: "localhost",
  pool_size: 10
