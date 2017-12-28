defmodule Monopoly.Resource do
  import Monopoly.Util

  defmodule Player do
    defstruct money: 1500, my_articles: [], position: :start, jail_times: 0, has_played_dice: true, ripdigid_times: 0
  end
  defmodule Article do
    defstruct house_num: 0, owner_name: nil, is_mortgage: false,
      mass_kind: :normal, # atom
    neighbors: [], # [atom]
    land_price: 0, # int
    rental_prices: [], # [int]
    construction_cost: 0, # int
    payment_func: nil # function(player_name, owner_name, neighbors, rental_prices, is_mortgage, house_num)
  end
  defmodule GameStatus do
    defstruct articles: [], players: []
  end # Monopoly.Resource.GameStatus

  def generate_game_status(players_name_list) do
    articles_data_list = [
      {:start, %Monopoly.Resource.Article{}},
      {:mediterranean, %Monopoly.Resource.Article{}},
      {:fund1, %Monopoly.Resource.Article{}}
    ]
    players_data_list = Enum.map players_name_list, fn(player_name) ->
      {player_name, %Monopoly.Resource.Player{}} end
    %Monopoly.Resource.GameStatus{articles: articles_data_list, players: players_data_list}
  end

  def set_player_property(
    %Monopoly.Resource.GameStatus{players: players_data_list} = game_status,
    player_name,
    property,
    value) do
    new_player_data = case property do
                        :money ->
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |money: value}
                        :position ->
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |position: value}
                        :jail_times ->
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |jail_times: value}
                        :has_played_dice ->
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |has_played_dice: value}
                        :ripdigid_times ->
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |ripdigid_times: value}
                      end
    new_players_data_list = change_taple(player_name, new_player_data, players_data_list)
    %Monopoly.Resource.GameStatus{ game_status |players: new_players_data_list}
  end
  def get_player_property(
    %Monopoly.Resource.GameStatus{players: players_data_list} = game_status,
    player_name,
    property) do
    player_data = find_taple(player_name, players_data_list)
    case property do
      :money ->
        %Monopoly.Resource.Player{money: val} = player_data
        val
      :position ->
        %Monopoly.Resource.Player{position: val} = player_data
        val
      :my_articles ->
        %Monopoly.Resource.Player{my_articles: val} = player_data
        val
      :jail_times ->
        %Monopoly.Resource.Player{jail_times: val} = player_data
        val
      :has_played_dice ->
        %Monopoly.Resource.Player{has_played_dice: val} = player_data
        val
      :ripdigid_times ->
        %Monopoly.Resource.Player{ripdigid_times: val} = player_data
        val
    end
  end
  def add_player_property(
    %Monopoly.Resource.GameStatus{players: players_data_list} = game_status,
    player_name,
    property,
    add_value) do
    new_player_data = case property do
                        :money ->
                          value = get_player_property(game_status, player_name, :money) + add_value
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |money: value}
                        :my_articles ->
                          value = get_player_property(game_status, player_name, property) ++ [add_value]
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |my_articles: value}
                        :jail_times ->
                          value = get_player_property(game_status, player_name, :jail_times) + add_value
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |jail_times: value}
                        :ripdigid_times ->
                          value = get_player_property(game_status, player_name, :ripdigid_times) + add_value
                          %Monopoly.Resource.Player{ find_taple(player_name, players_data_list) |ripdigid_times: value}
                      end
    new_players_data_list = change_taple(player_name, new_player_data, players_data_list)
    %Monopoly.Resource.GameStatus{ game_status |players: new_players_data_list}
  end

  def set_article_property(
    %Monopoly.Resource.GameStatus{articles: articles_data_list} = game_status,
    article_name,
    property,
    value) do
    new_article_data = case property do
                         :house_num ->
                           %Monopoly.Resource.Article{ find_taple(article_name, articles_data_list) |house_num: value}
                         :is_mortgage ->
                           %Monopoly.Resource.Article{ find_taple(article_name, articles_data_list) |house_num: value}
                         :owner_name ->
                           %Monopoly.Resource.Article{ find_taple(article_name, articles_data_list) |house_num: value}
                       end
    new_articles_data_list = change_taple(article_name, new_article_data, articles_data_list)
    %Monopoly.Resource.GameStatus{ game_status |articles: new_articles_data_list}
  end
  def get_article_property(
    %Monopoly.Resource.GameStatus{articles: articles_data_list} = game_status,
    article_name,
    property) do
    article_data = find_taple(article_name, articles_data_list)
    case property do
      :house_num ->
        %Monopoly.Resource.Article{house_num: val} = article_data
        val
      :owner_name ->
        %Monopoly.Resource.Article{owner_name: val} = article_data
        val
      :is_mortgage ->
        %Monopoly.Resource.Article{is_mortgage: val} = article_data
        val
      :mass_kind ->
        %Monopoly.Resource.Article{mass_kind: val} = article_data
        val
      :neighbors ->
        %Monopoly.Resource.Article{neighbors: val} = article_data
        val
      :land_price ->
        %Monopoly.Resource.Article{land_price: val} = article_data
        val
      :rental_prices ->
        %Monopoly.Resource.Article{rental_prices: val} = article_data
        val
      :construction_cost ->
        %Monopoly.Resource.Article{construction_cost: val} = article_data
        val
      :payment_func ->
        %Monopoly.Resource.Article{payment_func: val} = article_data
        val
    end
  end


end # Monopoly.Resource
