defmodule Monopoly.Event do

  @chance_server_name "csn"
  @fund_server_name "fsn"


  def getEventAction(kind) do
    case kind do
      :chance ->
        csn = :global.whereis_name(@chance_server_name)
        send csn, {:draw, self}
        receive do
          {func, csn} -> func
        end
      :fund ->
        fsn = :global.whereis_name(@fund_server_name)
        send fsn, {:draw, self}
        receive do
          {func, fsn} -> func
        end
    end
  end

  def deck_server([], discards) do
    deck = Enum.shuffle(discards)
    deck_server(deck, [])
  end
  def deck_server([h|deck], discards) do
    receive do
      {:draw, client} ->
        send client, {h, self}
        deck_server(deck, [h|discards])
    end
  end


  def init_event_server do
    chance_deck = [
      {:interest, fn(player_name) ->
      end}
    ] |> Enum.shuffle

    fund_deck = [
      {:go_boardwolk, fn(player_name) ->
      end}
    ] |> Enum.shuffle

    chance_server = spawn(__MODULE__, :deck_server, [chance_deck, []])
    :global.register_name(@chance_server_name, chance_server)
    fund_server = spawn(__MODULE__, :deck_server, [fund_deck, []])
    :global.register_name(@fund_server_name, fund_server)
  end


end # Monopoly.Event
