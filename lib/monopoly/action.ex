defmodule Monopoly.Action do

  def exec_action(
    input_server,
    player_name,
    game_status) do
    action_list = get_actions_list(player_name, game_status)
    send input_server, {:action, action_list, game_status, player_name, self}
    receive do
      {:n, nil, input_server} ->
        {:n, nil, game_status}
      msg ->
        IO.puts "receive an invalid message! (@exec_action)"
        {:f, nil, game_status}
    end
  end


  defp get_actions_list(player_name, game_status) do
    [:c, :n, :d, :t, :s, :b]
  end
  defp get_dice_values do
    first_val = :rand.uniform(6)
    second_val = :rand.uniform(6)
    {first_val==second_val, first_val+second_val}
  end

end # Monopoly.Action
