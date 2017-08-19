defmodule Koko.DocManagerSearchTest do
  use Koko.DataCase

  alias Koko.DocManager.Search

   test "by_query_string" do
      docs = Search.by_query_string(:document, "title=Magick&sort=title" , [])
      assert hd(docs).title =~ "Magick"
   end

end
