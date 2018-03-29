defmodule Koko.Web.CredentialsView do
  use Koko.Web, :view

#
# def render("credentials.json", %{credentials: credentials}) do
#   credentials
# end


def render("error.json", %{error: error}) do
  %{error: error}
end
#
def render("credentials.json", %{credentials: credentials}) do
  %{ url: credentials.url,
     credentials: %{
       acl: credentials.credentials.acl,
       "x-amz-credential": credentials.credentials.credential,
       "x-amz-date": credentials.credentials.date,
       "x-amz-algorithm": "AWS4-HMAC-SHA256",
       key: credentials.credentials.key,
       policy: credentials.credentials.policy,
       "x-amz-signature": credentials.credentials.policy,
    }
  }
end

# (field "x-amz-signature" Json.Decode.string)
#   (field "x-amz-date" Json.Decode.string)
#   (field "x-amz-credential" Json.Decode.string)
#   (field "x-amz-algorithm" Json.Decode.string)
#   (field "policy" Json.Decode.string)
#   (field "key" Json.Decode.string)
#   (field "acl" Json.Decode.string)
#
# AWSAccessKeyId: credentials.credentials.AWSAccessKeyId,

end
