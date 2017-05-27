use Mix.Config

config :koko, ecto_repos: [Koko.Repo]

# config :guardian, Guardian,
#   allowed_algos: ["HS512"], # optional
#   verify_module: Guardian.JWT,  # optional
#   issuer: "Koko",
#   ttl: { 30, :days },
#   allowed_drift: 2000,
#   verify_issuer: true, # optional
#   secret_key: "iYTjrtDZW3-pJ84AYCiM4P5CYJcOrbyKDcWNmKvSVQJ4i-j1BqmmEL88aX4Ayy9ap-_R0lG_0_wVSoIehXq03w",
#   serializer: Koko.GuardianSerializer

import_config "#{Mix.env}.exs"
