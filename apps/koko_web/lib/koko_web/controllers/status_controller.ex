defmodule Koko.Web.StatusController do

use Koko.Web, :controller

def hello(conn, _params) do
  render(conn, "hello.json")
end

end
