defmodule Koko.Document.QueryMacro do

  defmacro has_attribute(field, key, value) do
    quote do
      fragment("? @&gt; '{?: ?}'", unquote(field), unquote(key), unquote(value))
    end
  end

  defmacro in_any(left, right) do
    quote do
      fragment("? = ANY (?)", unquote(left), unquote(right))
    end
  end

end
