import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :janus, JanusWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "h2y8eKwOyAbuAus/xanbtl3Xt5rbqJtR0skp+dv8kVsmcp30jEkBOTm2CB/uXjvR",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
