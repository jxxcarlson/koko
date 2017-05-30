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
      IO.puts "FBC CALL (1)"
    conn
    |> put_status(:not_found)
    |> render(Koko.Web.ErrorView, :"404")
  end

  def call(conn, {:error, message}) do
    IO.puts "FBC CALL (2)"
    IO.puts "MESSAGE: #{message}"
    conn
    |> put_status(:not_found)
    |> render(Koko.Web.ErrorView, "error.json", error: message)
  end

  def call(_, _) do
      IO.puts "FBC CALL (4)"
    |> render(Koko.Web.ErrorView, :"501")
  end



end
