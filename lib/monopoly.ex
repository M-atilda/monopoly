defmodule Monopoly do
  import Monopoly.Util

  def main([name]) do
    Node.start String.to_atom(name)
    main_setup
  end
  def main_setup do
    {player_name, players_name_list} = start_helper
    IO.puts "let's monopoly."
    input_server = Monopoly.Input.generate_input_server(self)
    moderator = Monopoly.Moderator.generate_moderator(self, input_server, player_name, players_name_list)
    main_rooter(player_name, players_name_list, input_server, moderator)
  end
  def main_rooter(player_name, players_name_list, input_server, moderator) do
    receive do

      {:chat, msg, input_server} ->
        Enum.map players_name_list, fn(temp_player_name) ->
          send_player(temp_player_name, {:chat, msg, player_name, self}) end
        main_rooter(player_name, players_name_list, input_server, moderator)

      {:chat, msg, speaker, _client} ->
        IO.puts "[Chat] #{msg} (#{speaker})"
        main_rooter(player_name, players_name_list, input_server, moderator)

      {:next, new_players_name_list, _client} ->
        Process.exit(input_server, :kill)
        :timer.sleep 500
        send moderator, {:new_turn, new_players_name_list, self}
        [h|_] = new_players_name_list
        if h == player_name do
          IO.puts "[Game] your turn."
          new_input_server = Monopoly.Input.generate_input_server(self, true)
          send moderator, {:my_turn, new_input_server, self}
          main_rooter(player_name, new_players_name_list, new_input_server, moderator)
        else
          IO.puts "[Game] #{h}'s turn."
          new_input_server = Monopoly.Input.generate_input_server(self)
          main_rooter(player_name, new_players_name_list, new_input_server, moderator)
        end

      #NOTE: treat trade at top layer because it needs to make new input server
      {:trade, products, player_name, client} ->
        Process.exit(input_server, :kill)
        result = Monopoly.Input.reply_trade_offer(player_name, products)
        #NOTE: send message not to the node but to the process
        send client, {:trade, result, self}
        new_input_server = Monopoly.Input.generate_input_server(self)
        main_rooter(player_name, players_name_list, new_input_server, moderator)

      {kind, contents, player_name, _client} ->
        send moderator, {kind, contents, player_name, self}
        main_rooter(player_name, players_name_list, input_server, moderator)

      msg ->
        IO.puts "receive invalid message! (@main_rooter)"
        IO.inspect msg
        main_rooter(player_name, players_name_list, input_server, moderator)
    end
  end


  # helper
  #@return [{Pid, atom}] other players' information list
  defp start_helper do
    which_server_client = IO.gets "
m: make a room
j: join a room
please select >> "
    case String.at(which_server_client, 0) do
      "m" ->
        start_room_server
      "M" ->
        start_room_server
      "j" ->
        start_room_client
      "J" ->
        start_room_client
      _ ->
        IO.puts "please input correct character!"
        start_helper
    end
  end


  def start_signal_waiter(parent) do
    IO.gets "start(just hit Enter) >> "
    send parent, {:start, self}
  end
  defp start_room_server do
    player_name = get_line "your name >> "
    IO.puts "[Info] room server <#{player_name} (#{inspect Node.self})>"
    :global.register_name(player_name, self)
    # start the process for getting start signal at room master's machine
    start_signal_waiter = spawn(
      __MODULE__,
      :start_signal_waiter,
      [self])
    # only one events' deck server pair exists @room master's node
    Monopoly.Event.init_event_server
    room_server_inner(player_name, start_signal_waiter, [{Node.self, player_name}])
  end
  defp room_server_inner(room_master_name, start_signal_waiter, players_info_list) do
    receive do
      {:start, start_signal_waiter} ->
        shuffled_info_list = Enum.shuffle players_info_list
        Enum.map players_info_list, fn({_node, temp_player_name}) ->
          if temp_player_name != room_master_name do
            send_player(temp_player_name, {:start, shuffled_info_list, self})
          end end
        shuffled_name_list = Enum.map shuffled_info_list, fn({_node, temp_player_name}) ->
          temp_player_name end
        {room_master_name, shuffled_name_list}
      {:join, node, player_name, _room_client} ->
        new_players_info_list = [{node, player_name}|players_info_list]
        IO.puts "[Info] players"
        Enum.map new_players_info_list, fn({node, temp_player_name}) ->
          IO.puts "    #{temp_player_name} (#{Atom.to_string(node)})"
          if temp_player_name != room_master_name do
            send_player(temp_player_name, {:join, new_players_info_list, self})
          end end
        room_server_inner(room_master_name, start_signal_waiter, new_players_info_list)
      msg ->
        IO.puts "receive an invalid message! (@room_server_inner)"
        room_server_inner(room_master_name, start_signal_waiter, players_info_list)
    end
  end


  defp start_room_client do
    player_name = get_line("your name >> ")
    :global.register_name(player_name, self)
    room_server_node = String.to_atom(get_line("room master's node >> "))
    Node.connect(room_server_node)
    IO.inspect Node.list
    room_master_name = (get_line("room master's name >> "))
    send_player(room_master_name, {:join, Node.self, player_name, self})
    room_client_inner(player_name, :global.whereis_name room_master_name)
  end
  defp room_client_inner(player_name, room_master) do
    receive do
      {:join, players_info_list, room_server_pid} ->
        IO.puts "[Info] players"
        Enum.map players_info_list, fn({node, temp_player_name}) ->
          if !(node in Node.list), do: Node.connect(node)
          IO.puts "    #{temp_player_name} : #{Atom.to_string(node)}" end
        room_client_inner(player_name, room_master)
      {:start, players_info_list, room_master} ->
        players_name_list = Enum.map players_info_list, fn({_node, temp_player_name}) ->
          temp_player_name end
        {player_name, players_name_list}
      _ ->
        IO.puts "receive an invalid message! (@room_client_inner)"
        room_client_inner(player_name, room_master)
    end
  end


end # Monopoly
