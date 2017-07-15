# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :arena_server, ArenaServer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "v1aV3UlI9/Y3gUXT4BBrTOTFV/6dntbhewoT0tL505A39RmliaUfKx+FVik/J83c",
  render_errors: [view: ArenaServer.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ArenaServer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
