defmodule Koko.Web.ErrorView do
  use Koko.Web, :view

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("500.json", msg) do
    %{errors: msg}
  end

  def render("501.json", error) do
    %{errors: "This error could not be identified due to programmer laziness"}
  end

  def render("502.json", {:error, msg}) do
    %{errors: "This error contains a message"}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, _) do
    render "500.json", "Unknown error"
  end
end
