defmodule Monopoly.Input do
  import Monopoly.Util


  def input_server(is_my_turn, parent) do
    
    if is_my_turn do
      IO.puts "" # erase old prompt
      receive do
        {:action, actions_list, game_status, player_name, client} ->
          {action_kind, operands} = treat_action_input(parent, actions_list, player_name, game_status)
          send client, {action_kind, operands, self}
          if action_kind == :n do
            input_server(false, parent)
          else
            input_server(true, parent)
          end
        _ ->
          #TODO: impl
          nil
      end
    else
      kind = String.to_atom(get_char(""))
      case kind do
        :h ->
          print_help
        :c ->
          msg = get_line("(chat-message)>")
          send parent, {:chat, msg, self}
        _kind ->
          IO.puts "please input a correct character!"
      end
      input_server(is_my_turn, parent)
    end
  end

  def generate_input_server(parent, is_my_turn \\ false) do
    spawn(__MODULE__, :input_server, [is_my_turn, parent])
  end


  def reply_trade_offer(companion, products) do
    IO.puts "[Game] #{companion} submits a trade"
    IO.puts "       products #{inspect products}"
    #TODO: impl
  end


  defp select_action(actions_list) do
    IO.puts "[Game] action's list"
    Enum.reduce actions_list, 1, fn(kind, acm) ->
      IO.puts "#{acm}. #{kind}"
      acm+1
    end
    action_num = get_num "(action-number)> "
    if action_num < 0 || (length(actions_list)-1) < action_num do
      IO.puts "please select the action from above choices!"
      select_action(actions_list)
    else
      Enum.at(actions_list, action_num-1)
    end
  end

  defp input_action_operands(kind, player_name, game_status) do
    pass = nil
    case kind do
      :d ->
        # dice
        pass
      :t ->
        # trade
        pass
      :s ->
        # sell a house
        pass
      :b ->
        # build a house
        pass
    end
  end
  defp treat_action_input(parent, actions_list, player_name, game_status) do
    action_kind = select_action(actions_list)
    if action_kind in [:c, :n] do
      case action_kind do
        :c ->
          msg = get_line("(chat-message)>")
          send parent, {:chat, msg, self}
          treat_action_input(parent, actions_list, player_name, game_status)
        :n ->
          {:n, nil}
      end
    else
      operands = input_action_operands(action_kind, player_name, game_status)
      {action_kind, operands}
    end
  end

  defp print_help do
    IO.puts "
please input obeying the prompt (brief)>

the prompt is ...

  nothing
    you are not the turn player now.
    you can send a chat message by typing 'c',
      or read this manual by 'h'

  (chat-message)>
    please input your chat message(just a line).
    this message is sent to all the player.

  (action-number)>
    you are in turn.
    please select the next action from the above list,    and input its number.

"
  end

end # Monopoly.Input
