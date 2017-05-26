defmodule Koko.Application do
  @moduledoc """
  The Koko Application Service.

  The koko system business domain lives in this application.

  Exposes API to clients such as the `Koko.Web` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(Koko.Repo, []),
    ], strategy: :one_for_one, name: Koko.Supervisor)
  end
end
