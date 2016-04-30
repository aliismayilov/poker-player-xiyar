require 'json'

class Player

  VERSION = "Default Ruby folding player"

  attr_reader :game_state

  def initialize(game_state)
    @game_state = JSON.parse(game_state)
  end

  def bet_request
    minimum_possible_raise
  end

  def showdown
  end

  def minimum_possible_raise
    game_state['current_buy_in'] - game_state['players'][game_state['in_action']]['bet'] + game_state['minimum_raise'] + 1
  end
end
