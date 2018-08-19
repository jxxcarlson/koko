defmodule Koko.User.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Koko.User.User
  alias Koko.Document.Query
  alias Koko.Document.Document
  alias Koko.Repo


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
    field :active, :boolean
    field :document_count, :integer
    field :media_count, :integer
    field :verified, :boolean, default: false
    timestamps()
  end


  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username, :email, :password, :password_hash, :admin, :blurb,
      :public, :document_ids, :current_document_id, :active, :document_count, :media_count, :verified])
    |> validate_required([:name, :username, :email, :password])
  end

  def safe_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name,  :blurb,
      :public, :document_ids, :current_document_id, :active, :document_count, :media_count, :verified])
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


    def get_user(id) do
      result = Koko.Repo.get(User, id)
      case result do
        nil -> {:error, "request for user #{id} failed"}
        _ -> {:ok, result}
      end
    end

    def get_document_count(user_id) do 
      Document |> Query.has_author(user_id) |> Repo.all |> length
    end 

    def update_document_count(user) do 
      count = get_document_count(user.id)
      cs = safe_changeset(user, %{document_count: count})
      Repo.update(cs)
    end 

    def change_document_count(user, delta) do 
      cs = safe_changeset(user, %{document_count: user.document_count + delta})
      Repo.update(cs)
    end 

    def increment_media_count(user) do 
      cs = safe_changeset(user, %{media_count: user.media_count + 1})
      Repo.update(cs)
    end 

    # Set user with given id to verified = true
    def verify(user_id) do
      u = Repo.get(User, user_id)
      cs = safe_changeset(u, %{verfied: true})
      Repo.update(cs)
    end

end
