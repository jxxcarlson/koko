defmodule Koko.DocManagerTest do
  use Koko.DataCase

  alias Koko.DocManager.Search

   test "by_command_list" do
      docs = Search.by_command_list([["title", "Magick"], ["sort", "title"]])
      assert hd(docs).title == "Magick"
   end

   test "by_query_string" do
      docs = Search.by_query_string("title=Magick&sort=title")
      assert hd(docs).title == "Magick"
   end

end
