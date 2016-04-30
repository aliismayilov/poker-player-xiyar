require 'json'

class Player

  VERSION = "Default Ruby folding player"

  attr_reader :game_state

  def initialize(game_state)
    @game_state = JSON.parse(game_state)
  end

  def bet_request
    return minimum_possible_raise + 200 if have_pair?
    return 0 if game_state['current_buy_in'] >= 400
    minimum_possible_raise + 1
  end

  def showdown
  end

  private

  def minimum_possible_raise
    game_state['current_buy_in'] - game_state['players'][game_state['in_action']]['bet'] + game_state['minimum_raise'] + 1
  end

  def have_pair?
    hole_cards.map do |card|
      card['rank']
    end.uniq.count == 1
  end

  def hole_cards
    game_state['players'].select do |player|
      player['hole_cards']
    end.first['hole_cards']
  end
end
