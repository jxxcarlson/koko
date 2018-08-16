
defmodule Koko.Image do

    use Ecto.Schema
    import Ecto.Changeset
  
    alias Koko.Repo
    alias Koko.Image
  
  
    schema "images" do
      field :name, :string
      field :user_id, :integer
      field :tags, {:array, :string}
      field :url, :string
      field :public, :boolean
      field :source, :string
  
      timestamps()
    end

    @doc false
    def changeset(%Image{} = image, attrs) do
        image
        |> cast(attrs, [:name, :user_id, :tags, :url, :public, :source])
        |> validate_required([:name, :user_id, :url])
    end



end
