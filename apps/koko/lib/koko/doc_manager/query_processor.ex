defmodule Koko.DocManager.QP do

  alias Koko.DocManager.Query
  alias Koko.DocManager.Document
  alias Koko.Repo
  alias Koko.DocManager.Query


  defmacro query1(command_list) do
     [cmd0, arg0] = Enum.at command_list, 0
     quote do
        Document
          |> Query.by(unquote(cmd0),unquote(arg0))
          |> Repo.all
     end
  end

  defmacro query2(command_list) do
     [cmd0, arg0] = Enum.at command_list, 0
     [cmd1, arg1] = Enum.at command_list, 1
     quote do
        Document
          |> Query.by(unquote(cmd0),unquote(arg0))
          |> Query.by(unquote(cmd1),unquote(arg1))
          |> Repo.all
     end
  end

  defmacro query3(command_list) do
     [cmd0, arg0] = Enum.at command_list, 0
     [cmd1, arg1] = Enum.at command_list, 1
     [cmd2, arg2] = Enum.at command_list, 2
     quote do
        Document
          |> Query.by(unquote(cmd0),unquote(arg0))
          |> Query.by(unquote(cmd1),unquote(arg1))
          |> Query.by(unquote(cmd2),unquote(arg2))
          |> Repo.all
     end
  end

  defmacro query4(command_list) do
     [cmd0, arg0] = Enum.at command_list, 0
     [cmd1, arg1] = Enum.at command_list, 1
     [cmd2, arg2] = Enum.at command_list, 2
     [cmd3, arg3] = Enum.at command_list, 3
     quote do
        Document
          |> Query.by(unquote(cmd0),unquote(arg0))
          |> Query.by(unquote(cmd1),unquote(arg1))
          |> Query.by(unquote(cmd2),unquote(arg2))
          |> Query.by(unquote(cmd3),unquote(arg3))
          |> Repo.all
     end
  end

  defmacro query5(command_list) do
     [cmd0, arg0] = Enum.at command_list, 0
     [cmd1, arg1] = Enum.at command_list, 1
     [cmd2, arg2] = Enum.at command_list, 2
     [cmd3, arg3] = Enum.at command_list, 3
     [cmd4, arg4] = Enum.at command_list, 3
     quote do
        Document
          |> Query.by(unquote(cmd0),unquote(arg0))
          |> Query.by(unquote(cmd1),unquote(arg1))
          |> Query.by(unquote(cmd2),unquote(arg2))
          |> Query.by(unquote(cmd3),unquote(arg3))
          |> Query.by(unquote(cmd4),unquote(arg4))
          |> Repo.all
     end
  end



   ########


   defmacro title(query, arg) do
     quote do
       Query.select_by_title(unquote(query), unquote(arg))
     end
   end

   defmacro sort(query, arg) do
     if arg == "title" do
         quote do
           Query.sort_by_title(unquote(query))
         end
     else
         query
     end
   end

  defmacro macro(code) do
    IO.inspect code
    newcode = quote do: IO.puts "Whatever."
    IO.inspect newcode
    newcode
  end


end
