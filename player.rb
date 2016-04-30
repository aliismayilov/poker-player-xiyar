require 'json'

class Player

  VERSION = "Default Ruby folding player"

  attr_reader :game_state

  def initialize(game_state)
    @game_state = JSON.parse(game_state)
  end

  def bet_request
    return minimum_possible_raise + 1500 if have_double_pair?
    return minimum_possible_raise + rank_to_value[ranks(hole_cards).first] if have_pair?
    return 0 if game_state['current_buy_in'] >= 400
    minimum_possible_raise + 1
  end

  def showdown
  end

  private

  def rank_to_value
    {
      'A' => 3000,
      'K' => 3000,
      'Q' => 1500,
      'J' => 1000,
      '10' => 800,
      '9' => 500,
      '8' => 400,
      '7' => 300,
      '6' => 200,
      '5' => 100,
      '4' => 100,
      '3' => 100,
      '2' => 100
    }
  end

  def minimum_possible_raise
    game_state['current_buy_in'] - game_state['players'][game_state['in_action']]['bet'] + game_state['minimum_raise'] + 1
  end

  def have_double_pair?
    all_ranks = ranks(hole_cards) + ranks(community_cards)
    all_ranks.select { |e| all_ranks.count(e) > 1 }.uniq.count > 1
  end

  def have_pair?
    ranks(hole_cards).uniq.count == 1
  end

  def hole_cards
    game_state['players'].select do |player|
      player['hole_cards']
    end.first['hole_cards']
  end

  def community_cards
    game_state['community_cards'] || []
  end

  def ranks(cards)
    return [] if cards.empty?
    cards.map do |card|
      card['rank']
    end
  end
end
