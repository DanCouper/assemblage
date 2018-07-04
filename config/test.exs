use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :assemblage, AssemblageWeb.Endpoint,
  http: [port: 5001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :assemblage, Assemblage.Repo,
  username: "postgres",
  password: "postgres",
  database: "assemblage_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
