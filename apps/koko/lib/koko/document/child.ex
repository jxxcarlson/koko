
# alias Koko.Repo; alias Koko.DocManager.Document
# doc = Repo.get(Document, 1)
# https://robots.thoughtbot.com/embedding-elixir-structs-in-ecto-models
# http://blog.simonstrom.xyz/w/
# http://blog.plataformatec.com.br/2015/08/working-with-ecto-associations-and-embeds/
# ch = [%Child{ level: 2, title: "Foo", doc_id: 33, doc_identifier: "jxx.foo.abc"}]
defmodule Koko.Document.Child do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :level, :integer
    field :title, :string
    field :doc_id, :integer
    field :doc_identifier, :string
    field :comment, :string
  end

  def changeset(%Child{} = child, attrs) do
    child
    |> cast(attrs, [:level, :title, :doc_id, :doc_identifier, :comment])
  end


end
