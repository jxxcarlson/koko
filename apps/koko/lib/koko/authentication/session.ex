defmodule Koko.Authentication.Session do
  use Ecto.Schema
  import Ecto.Changeset
  alias Koko.Authentication.Session


  schema "authentication_sessions" do
    field :token, :string
    # field :user_id, :id

    # timestamps()
  end

  @doc false
  def changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:token])
    |> validate_required([:token])
  end

end
