defmodule Koko.Archive.Archive do

  # https://hexdocs.pm/ecto/getting-started.html

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Koko.Repo
  alias Koko.Archive.Archive

  schema "archives" do
    field :name, :string
    field :author_id, :integer
    field :bucket, :string
    field :url, :string
    field :remarks, :string

    timestamps()
  end

  def changeset(%Archive{} = archive, attrs) do
    archive
    |> cast(attrs, [:name, :bucket, :author_id, :url, :remarks])
    |> validate_required([:bucket, :name, :author_id])
  end

  def create(bucket, name, author_id, remarks) do

    attrs = %{name: name,
              author_id: author_id,
              bucket: bucket,
              remarks: remarks}

    %Archive{}
      |>  changeset(attrs)
      |> Repo.insert()
  end

  def get_by_name_and_author(archive_name, author_id) do
    query = from archive in "archives",
          where: archive.name == ^archive_name,
          select: [archive.id, archive.author_id]
    data = Repo.all(query)
      |> Enum.filter(fn(item) -> hd(tl(item)) == author_id end)
    if length(data) == 1 do
      id = hd(hd(data))
      Koko.Repo.get(Archive, id)
    else
      nil
    end
  end

end
