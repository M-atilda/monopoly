defmodule Monopoly.Util do

  def send_player(user_name, msg) do
    send :global.whereis_name(user_name), msg
  end

  def get_line(msg) do
    str = IO.gets msg
    len = String.length str
    String.slice str, 0, (len-1)
  end

  def get_char(msg) do
    str = get_line(msg)
    if (String.length str) != 1 do
      IO.puts "please input 'a' character!"
      get_char msg
    else
      String.at(str, 0)
    end
  end
  def get_num(msg) do
    num_str = get_line msg
    try do
      String.to_integer num_str
    rescue
      _ ->
        IO.puts "please input a number!"
        get_num(msg)
    end
  end

  def find_taple(first_factor, taples_list) do
    Enum.reduce taples_list, nil, fn({f, s}, acm) ->
      if first_factor == f do
        s
      else
        acm
      end end
  end
  def change_taple(first_factor, second_factor, taples_list) do
    Enum.reduce taples_list, [], fn({f, s}, acm) ->
      if first_factor == f do
        acm ++ [{first_factor, second_factor}]
      else
        acm ++ [{f, s}]
      end end
  end

end # Monopoly.Util
