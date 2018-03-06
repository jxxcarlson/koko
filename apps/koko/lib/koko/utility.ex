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


  def get_with_prefix(list, prefix) do
    Enum.filter(list, fn(item) -> String.starts_with? item, prefix end)
  end

  def remove_item(list, item_to_remove) do
    Enum.filter(list, fn(item) -> not (String.starts_with? item, item_to_remove) end)
  end

  def normalize_string(str) do
    Regex.replace(~r/[^A-Za-z0-9_.: ]/, str, "") |> String.replace(" ", "_")
  end

  def project2map(input) do
    if is_binary(input) do
      {:ok, decoded} = Poison.Parser.parse input
      decoded
    else
      input
    end
  end


  # Example yada | foo |> Utility.inspect_pipe("FOO")
  def inspect_pipe(arg, message) do
    IO.puts message
    IO.inspect(arg)
    IO.puts "-----------------"
    arg
  end

  def ok_message(message) do
    IO.puts message
    {:ok, message}
  end

  def nice_date_time(item_info) do
     info = item_info |> tl |> tl |> tl |> hd
     ymd = elem(info, 0)
     hmst = elem(info, 1)

     year = elem(ymd, 0)
     month = elem(ymd, 1)
     day = elem(ymd, 2)

     hour = elem(hmst, 0)
     minute = elem(hmst, 1)
     second = elem(hmst, 2)

     "UTC #{year}-#{month}-#{day}, #{hour}:#{minute}:#{second}"
  end

end
