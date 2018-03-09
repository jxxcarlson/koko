defmodule Koko.Document.Access do

  alias Koko.Document.Document


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

  def can_read(document, user) do
    document.author_id == user.id
    || document.attributes["public"] == true
    || String.contains? get_user_access(document, user.username), "r"
  end

  def can_read(document, user_id, username) do
    document.author_id == user_id
    || document.attributes["public"] == true
    || String.contains? get_user_access(document, username), "r"
  end

  def can_write(document, user) do
    document.author_id == user.id
    || String.contains? get_user_access(document, user.username),   "w"
  end

  def access_granted(document, user, action) do
    case action do
      :read -> can_read(document, user)
      :write -> can_write(document, user)
      true -> false
    end
  end


end
