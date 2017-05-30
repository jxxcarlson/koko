defmodule Koko.Web.ErrorView do
  use Koko.Web, :view

  def render("error.json", %{error: message}) do
    %{error: message}
  end

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{info: "Due to programmer laziness, I cannot say more about this error."}}
  end

  def render("501.json", stuff) do
    %{errors: stuff.message}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end

end
