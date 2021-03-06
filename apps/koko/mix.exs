defmodule Koko.Mixfile do
  use Mix.Project

  def project do
    [app: :koko,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Koko.Application, []},
     extra_applications: [:bamboo, :logger, :runtime_tools, :ex_aws, :hackney, :poison, :arc_ecto, :calendar]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]


  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:postgrex, ">= 0.13.3"},
     {:ecto, "~> 2.2.1"},
     {:corsica, "~> 0.5"},
     {:comeonin, "~> 2.0"},
     {:json, "~> 1.0.2"},
     {:joken, "~> 1.5.0"},
     {:secure_random, "~> 0.2"},
     {:arc, "~> 0.8.0"},
     {:ex_aws, "~> 1.1.4"},
     {:hackney,"~> 1.8.6"},
     {:poison, "~> 3.1"},
     {:sweet_xml, "~> 0.6"},
     {:arc_ecto, "~> 0.7.0"},
     {:s3_direct_upload, "~> 0.1.3"},
     {:sigaws, "~> 0.7"},
     {:bamboo, "~> 0.8"},
     { :uuid, "~> 1.1" },
     {:calendar, "~> 0.14.0"}]
  end



  # {:s3_direct_upload, git: "https://github.com/jxxcarlson/s3_direct_upload"},
  # {:s3_direct_upload, path: "/Users/carlson/dev/apps/s3_direct_upload_aws4/"},

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
