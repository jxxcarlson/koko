defmodule Koko.DocManagerTest do
  use Koko.DataCase

  alias Koko.Repo
  alias Koko.DocManager.Document
  alias Koko.DocManager.QP
  alias Koko.DocManager.Query
  alias Koko.DocManager.Search


  require Koko.DocManager.QP

   test "title macro" do
      docs = Document |> QP.title("Magick") |> Repo.all
      assert hd(docs).title == "Magick"
   end

   test "sort macro" do
      docs = Document |> QP.sort("title") |> Repo.all
      doc0 = Enum.at(docs, 0)
      doc1 = Enum.at(docs, 1)
      assert doc0.title < doc1.title
   end

   test "query_by" do
      docs = Document |> Query.by("title", "Magick") |> Repo.all
      assert hd(docs).title == "Magick"
   end

   test "query1" do
      docs = QP.query1([["title", "Magick"]])
      assert hd(docs).title == "Magick"
   end

   test "query2" do
      docs = QP.query2([["title", "Magick"], ["title", "Magick"]])
      assert hd(docs).title == "Magick"

      docs = QP.query2([["title", "Magick"], ["sort", "title"]])
      assert hd(docs).title == "Magick"

      docs = QP.query2([["title", "Magick"], ["title", "tree"]])
      assert docs == []
   end

  #  test "by_command_list" do
  #     docs = Search.by_command_list([["title", "Magick"], ["sort", "title"]])
  #     assert hd(docs).title == "Magick"
  #  end
   #
  #  test "by_query_string" do
  #     docs = Search.by_query_string("title=Magick&sort=title")
  #     assert hd(docs).title == "Magick"
  #  end

  #  test "command macro" do
  #    docs =  Document |> QP.command(["title", "Magick"]) |> Repo.all
  #    assert hd(docs).title == "Magick"
  #  end

end
