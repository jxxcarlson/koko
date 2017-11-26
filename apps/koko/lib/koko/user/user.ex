defmodule Koko.User.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Koko.User.User


  schema "authentication_users" do
    field :admin, :boolean, default: false
    field :blurb, :string
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :username, :string
    field :public, :boolean, default: true
    field :document_ids, {:array, :integer}
    field :current_document_id, :integer
    timestamps()
  end


  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username, :email, :password, :password_hash, :admin, :blurb, :public])
    |> validate_required([:name, :username, :email, :password])
  end

  def minimal_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:blurb])
  end

  def user_state_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:current_document_id, :document_ids])
  end

  def registration_changeset(%User{} = user, params \\ :empty) do
      user
      |> changeset(params)
      |> cast(params, ~w(password))
      #|> validate_length(:password, min: 6)
      |> put_password_hash
    end

    defp put_password_hash(changeset) do

      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
          put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
        _ ->
          changeset
      end
    end

end
