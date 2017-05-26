defmodule Koko.Authentication.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Koko.Authentication.User


  schema "authentication_users" do
    field :admin, :boolean, default: false
    field :blurb, :string
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username, :email, :password_hash, :admin, :blurb])
    |> validate_required([:name, :username, :email, :password_hash, :admin, :blurb])
  end
end
