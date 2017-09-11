defmodule Koko.SearchTest do
  use ExUnit.Case, async: true
  doctest Koko.Document.Search
end

defmodule Koko.QueryTest do
  use ExUnit.Case, async: true
  doctest Koko.Document.Query
end

defmodule Koko.DocumentTest do
  use ExUnit.Case, async: true
  doctest Koko.Document.Document
end
