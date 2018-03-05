defmodule Koko.Archive.Archive do

  # https://hexdocs.pm/ecto/getting-started.html

  use Ecto.Schema
  import Ecto.Changeset

  alias Koko.Repo
  alias Koko.Archive.Archive

  schema "archives" do
    field :name, :string
    field :author_id, :integer
    field :url, :string
    field :remarks, :string

    timestamps()
  end

  def changeset(%Archive{} = archive, attrs) do
    archive
    |> cast(attrs, [:name, :author_id, :url, :remarks])
    |> validate_required([:name, :author_id, :url])
  end

end
