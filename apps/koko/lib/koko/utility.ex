defmodule Koko.Utility do

  @doc """
  get_value_of_key(key, map) gets the value
  of the key in the given map regardless
  of the format (string, atom).

  Let m = %{foo: 1, bar: 2}. Then
     m[:foo] == 1
     m["foo"] == 1
  Let m = %{"foo" => 1, "bar" => 2}.  Then
     m[:foo] == 1, m["foo"] == 1
  """
  def get_value_of_key(key, map) do
    key = if is_atom(key) do
      to_string(key)
    else
      key
    end
    map[key] || map[String.to_atom(key)]
  end


  ### A BETTER WAY:
  # def do_something_with_map_key({:foo, foo} = map} do
  #    # do something
  # end



  def project2map(input) do
    if is_binary(input) do
      {:ok, decoded} = Poison.Parser.parse input
      decoded
    else
      input
    end
  end

end
