defmodule Koko.Repo do
  use Ecto.Repo, otp_app: :koko
  

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
    # {:ok, Keyword.put(opts, :url, "koko_dev")}
  end
end
