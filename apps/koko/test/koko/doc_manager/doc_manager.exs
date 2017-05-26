defmodule Koko.DocManagerTest do
  use Koko.DataCase

  alias Koko.DocManager

  describe "documents" do
    alias Koko.DocManager.Document

    @valid_attrs %{content: "some content", rendered_content: "some rendered_content", title: "some title"}
    @update_attrs %{content: "some updated content", rendered_content: "some updated rendered_content", title: "some updated title"}
    @invalid_attrs %{content: nil, rendered_content: nil, title: nil}

    def document_fixture(attrs \\ %{}) do
      {:ok, document} =
        attrs
        |> Enum.into(@valid_attrs)
        |> DocManager.create_document()

      document
    end

    test "list_documents/0 returns all documents" do
      document = document_fixture()
      assert DocManager.list_documents() == [document]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert DocManager.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document" do
      assert {:ok, %Document{} = document} = DocManager.create_document(@valid_attrs)
      assert document.content == "some content"
      assert document.rendered_content == "some rendered_content"
      assert document.title == "some title"
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DocManager.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()
      assert {:ok, document} = DocManager.update_document(document, @update_attrs)
      assert %Document{} = document
      assert document.content == "some updated content"
      assert document.rendered_content == "some updated rendered_content"
      assert document.title == "some updated title"
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture()
      assert {:error, %Ecto.Changeset{}} = DocManager.update_document(document, @invalid_attrs)
      assert document == DocManager.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = DocManager.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> DocManager.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = DocManager.change_document(document)
    end
  end
end
