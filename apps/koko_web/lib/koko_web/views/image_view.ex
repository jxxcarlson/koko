defmodule Koko.Web.ImageView do
    use Koko.Web, :view
  
    def render("reply.json", params) do
        %{reply: params.reply}
    end

end