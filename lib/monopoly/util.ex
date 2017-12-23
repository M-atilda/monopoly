defmodule Monopoly.Util do

  def send_user(user_name, msg) do
    send :global.whereis_name(user_name), msg
  end

  def get_line(msg) do
    str = IO.gets msg
    len = String.length str
    String.slice str, 0, (len-1)
  end

end
