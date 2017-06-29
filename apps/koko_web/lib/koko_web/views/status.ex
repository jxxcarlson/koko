defmodule Koko.Web.StatusView do
  use Koko.Web, :view
  alias Koko.Web.StatusView

  def render("hello.json", _) do
    %{status: "OK"}
  end

end
