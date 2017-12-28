defmodule Monopoly.Moderator do
  import Monopoly.Util

  def moderator(parent, input_server, player_name, players_name_list, game_status) do
    receive do

      {:new_turn, new_players_name_list, parent} ->
        moderator(parent, input_server, player_name, new_players_name_list, game_status)

      {:status, new_game_status, parent} ->
        Monopoly.Output.show_game_status(new_game_status)
        moderator(parent, input_server, player_name, players_name_list, new_game_status)

      {:action, action_detail, temp_player_name, parent} ->
        IO.puts "[Game] #{temp_player_name}'s action ... #{action_detail}"
        moderator(parent, input_server, player_name, players_name_list, game_status)

      {:my_turn, new_input_server, parent} ->
        {action_kind, operands, new_game_status} = Monopoly.Action.exec_action(new_input_server, player_name, game_status)
        action_detail = make_action_detail(action_kind, operands)
        Enum.map players_name_list, fn(temp_player_name) ->
          if action_kind == :n do
            [h|t] = players_name_list
            new_players_name_list = t ++ [h]
            send_player(temp_player_name, {:next, new_players_name_list, self})
          else
            if player_name != temp_player_name do
              send_player(temp_player_name, {:action, action_detail, player_name, self})
              send_player(temp_player_name, {:status, new_game_status, self})
            end
          end end
        moderator(parent, new_input_server, player_name, players_name_list, game_status)
    end
  end

  def generate_moderator(parent, input_server, player_name, [head_name|_] = players_name_list) do
    pid = spawn(
      __MODULE__,
      :moderator,
      [parent, input_server, player_name, players_name_list, Monopoly.Resource.generate_game_status(players_name_list)])

    # send a signal to start the first turn
    if player_name == head_name do
      send_start_signal = fn ->
        :timer.sleep 1000
        Enum.map players_name_list, fn(temp_player_name) ->
          send_player(temp_player_name, {:next, players_name_list, self}) end end
      spawn send_start_signal
    end
    pid
  end


  defp make_action_detail(action_kind, operands) do
    case action_kind do
      _ ->
        inspect operands
    end
  end

end # Monopoly.Moderator
