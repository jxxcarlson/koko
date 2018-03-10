defmodule Koko.Document.Access do

  alias Koko.Document.Document
  alias Koko.Repo


    def set_user_access(document, username, access_type) do
    valid_access_type = if access_type in ["", "r", "w", "rw"] do
      access_type
    else
      ""
    end
    new_access = if document.access == nil do
           %{username => valid_access_type}
        else
           Map.merge(document.access, %{username => valid_access_type})
        end
    cs = Document.changeset(document, %{access: new_access})
    Repo.update(cs)
    new_access
  end

  def get_user_access(document, username) do
    if document.access == nil do
       "INVALID"
    else
       document.access[username]
    end
  end

  defp can_read(document, user_id, username) do
    document.author_id == user_id
    || document.attributes["public"] == true
    || String.contains? get_user_access(document, username), "r"
  end

  defp can_read_shared(document, user_id, username) do
     String.contains? get_user_access(document, username), "r"
  end

  defp can_write(document, user_id, username) do
    document.author_id == user_id
    || String.contains? get_user_access(document, username), "w"
  end

  def access_granted(document, user_id, username, action) do
    case action do
      :read -> can_read(document, user_id, username)
      :write -> can_write(document, user_id, username)
      true -> false
    end
  end

  def shared_access_granted(document, user_id, username, action) do
    case action do
      :read -> can_read_shared(document, user_id, username)
      :write -> can_write(document, user_id, username)
      true -> false
    end
  end


end
