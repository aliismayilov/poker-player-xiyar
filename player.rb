require 'json'

class Player

  VERSION = "Default Ruby folding player"

  attr_reader :game_state

  def initialize(game_state)
    @game_state = JSON.parse(game_state)
  end

  def bet_request
    return all_in_bet if flush? || three_of_a_rank? || double_pair?
    return minimum_bet + available_for_raise / rank_to_value[ranks(hole_cards).first] if pair?
    return minimum_bet + 1 if going_for_flush?
    return 0 if one_of_the_players_is_too_sure?
    return 0 unless have_high?
    minimum_bet + 1
  end

  def showdown
  end

  private

  def going_for_flush?
    hole_cards.map do |card|
      card['suit']
    end.uniq.count == 1
  end

  def have_high?
    hole_cards
      .any? do |card|
        ['A', 'K', 'Q'].include?(card['rank'])
      end
  end

  def all_in_bet
    minimum_bet + available_for_raise
  end

  def flush?
    all_cards
      .group_by do |card|
        card['suit']
      end
      .any? do |suit, cards|
        cards.count > 4
      end
  end

  def one_of_the_players_is_too_sure?
    other_players.any? do |player|
      player['bet'].to_i > player['stack'].to_i
    end
  end

  def available_for_raise
    my_stack - minimum_bet
  end

  def rank_to_value
    {
      'A' => 1,
      'K' => 1,
      'Q' => 1.5,
      'J' => 1.7,
      '10' => 2,
      '9' => 2.5,
      '8' => 3,
      '7' => 4,
      '6' => 10,
      '5' => 10,
      '4' => 10,
      '3' => 10,
      '2' => 10
    }
  end

  def all_ranks
    ranks(hole_cards) + ranks(community_cards)
  end

  def all_cards
    hole_cards + community_cards
  end

  def three_of_a_rank?
    all_ranks.any? do |rank|
      all_ranks.count(rank) > 2
    end
  end

  def minimum_bet
    game_state['current_buy_in'] - game_state['players'][game_state['in_action']]['bet'] + game_state['minimum_raise'] + 1
  end

  def double_pair?
    all_ranks.select { |e| all_ranks.count(e) > 1 }.uniq.count > 1
  end

  def pair?
    ranks(hole_cards).uniq.count == 1
  end

  def hole_cards
    my_player['hole_cards']
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

  def my_player
    game_state['players'].select do |player|
      player['hole_cards'] && player['hole_cards'].any?
    end.first
  end

  def other_players
    game_state['players'].reject do |player|
      player['hole_cards'] && player['hole_cards'].any?
    end
  end

  def my_stack
    my_player['stack']
  end
end
