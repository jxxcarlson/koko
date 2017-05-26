use Mix.Config

config :koko, ecto_repos: [Koko.Repo]

import_config "#{Mix.env}.exs"
