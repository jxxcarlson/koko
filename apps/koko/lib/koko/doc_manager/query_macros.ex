defmodule Koko.DocManager.QueryMacro do

  defmacro has_attribute(field, key, value) do
    quote do
      fragment("? @&gt; '{?: ?}'", unquote(field), unquote(key), unquote(value))
    end
  end

end
