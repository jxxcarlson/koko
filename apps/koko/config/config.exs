use Mix.Config

config :koko, ecto_repos: [Koko.Repo]

config :arc,
  storage: Arc.Storage.S3, # or Arc.Storage.Local
  bucket: "noteimages"

# check config with
#
#  Application.get_env :ex_aws, :access_key_id
#
config :ex_aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")



import_config "#{Mix.env}.exs"
