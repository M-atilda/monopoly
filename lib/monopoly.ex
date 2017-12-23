defmodule Monopoly do
  import Monopoly.Util


  def main() do
    players_info_list = start_helper()
    IO.puts "let's monopoly."
    moderator = spawn(Monopoly.Moderator, :moderator, [players_info_list])
  end


  # helper
  #@return [{Pid, atom}] other players' information list
  defp start_helper() do
    which_server_client = IO.gets "
m: make a room
j: join a room
please select >> "
    case String.at(which_server_client, 0) do
      "m" ->
        start_room_server()
      "M" ->
        start_room_server()
      "j" ->
        start_room_client()
      "J" ->
        start_room_client()
      _ ->
        IO.puts "please input correct character!"
        start_helper()
    end
  end


  #TODO: encapsulate(conflict with spawn)
  def start_signal_waiter(parent) do
    IO.gets "start(just hit Enter) >> "
    send parent, {:start, self()}
  end
  defp start_room_server() do
    user_name = get_line("your name >> ")
    IO.puts "[Info] room server <#{user_name} (#{inspect Node.self()})>"
    :global.register_name(user_name, self())
    # start the process for getting start signal at room master's machine
    start_signal_waiter = spawn(__MODULE__, :start_signal_waiter, [self()])
    room_server_inner(user_name, start_signal_waiter, [{Node.self(), user_name}])
  end
  defp room_server_inner(room_master_name, start_signal_waiter, players_info_list) do
    receive do
      {:start, start_signal_waiter} ->
        Enum.map players_info_list, fn({_node, user_name}) ->
          if user_name != room_master_name do
            send_user(user_name, {:start, players_info_list, self()})
          end
          user_name end
      {:join, node, user_name, _room_client} ->
        new_players_info_list = [{node, user_name}|players_info_list]
        IO.puts "[Info] players"
        Enum.map new_players_info_list, fn({node, user_name}) ->
          IO.puts "    #{user_name} (#{Atom.to_string(node)})"
          if user_name != room_master_name do
            send_user(user_name, {:join, new_players_info_list, self()})
          end end
        room_server_inner(room_master_name, start_signal_waiter, new_players_info_list)
      msg ->
        IO.puts "receive an invalid message!"
        IO.inspect msg
        room_server_inner(room_master_name, start_signal_waiter, players_info_list)
    end
  end


  defp start_room_client() do
    user_name = get_line("your name >> ")
    :global.register_name(user_name, self())
    room_server_node = String.to_atom(get_line("room master's node >> "))
    Node.connect(room_server_node)
    IO.inspect Node.list()
    room_master_name = (get_line("room master's name >> "))
    send_user(room_master_name, {:join, Node.self(), user_name, self()})
    room_client_inner(:global.whereis_name(room_master_name))
  end
  defp room_client_inner(room_master) do
    receive do
      {:join, players_info_list, room_server_pid} ->
        IO.puts "[Info] players"
        Enum.map players_info_list, fn({node, user_name}) ->
          if !(node in Node.list()), do: Node.connect(node)
          IO.puts "    #{user_name} : #{Atom.to_string(node)}" end
        room_client_inner(room_master)
      {:start, players_info_list, room_master} ->
        Enum.map players_info_list, fn({_node, user_name}) ->
          user_name end
      _ ->
        IO.puts "receive an invalid message!"
        room_client_inner(room_master)
    end
  end


end # Monopoly
