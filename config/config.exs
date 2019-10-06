# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :live_todos,
  ecto_repos: [LiveTodos.Repo]

# Configures the endpoint
config :live_todos, LiveTodosWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mgSgyBDh3J5k8O1xWny8DyVQcOTldAzxF/NY7bU0NyPDvSyMWIUuy9eixW6a6HpH",
  render_errors: [view: LiveTodosWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveTodos.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
