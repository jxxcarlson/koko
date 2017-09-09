defmodule Koko.DocManagerSearchTest do
  use Koko.DataCase

  alias Koko.Document.Search

   test "by_query_string" do
      docs = Search.by_query_string(:document, "title=Elm&sort=title" , [])
      assert hd(docs).title =~ "Elm"
   end

   test "random" do
     n = Search.random("user_id=1") |> length
     assert n == 10
   end

end
