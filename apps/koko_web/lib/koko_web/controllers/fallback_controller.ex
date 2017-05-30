defmodule Koko.Web.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Koko.Web, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Koko.Web.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
      IO.puts "FB CALL (1)"
    conn
    |> put_status(:not_found)
    |> render(Koko.Web.ErrorView, :"404")
  end

  def call(conn, {:error, error}) do
    IO.puts "FB CALL (2)"
    IO.inspect error
    conn
    |> put_status(:not_found)
    |> render(Koko.Web.ErrorView, error)
  end



  def call(conn, {:error, msg}) do
      IO.puts "FB CALL (3)"
      IO.puts "111---------------------------------"
      IO.inspect msg
      IO.puts "111---------------------------------"

    # IO.inspect msg
    # {:error, message} = msg
    # IO.puts "MSG: #{msg}"
    conn
    |> put_status(:not_found)
    |> Koko.Utility.conn_message("HERE I AM (1)")
    |> render(Koko.Web.ErrorView, :"500")
  end

  def call(conn, _) do
      IO.puts "FB CALL (4)"
    # |> put_status(:not_found)
    |> Koko.Utility.conn_message("HERE I AM (2)")
    |> render(Koko.Web.ErrorView, :"501")
  end



end
