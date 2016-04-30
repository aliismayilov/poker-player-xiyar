require_relative 'player'
require 'rspec'

RSpec.describe Player do
  it 'has version' do
    expect(Player::VERSION).to eql 'Default Ruby folding player'
  end

  subject(:player) { Player.new(game_state) }

  let(:current_buy_in) { 100 }
  let(:hole_cards) do
    [
      {
        "rank": "6",
        "suit": "hearts"
      },
      {
        "rank": "K",
        "suit": "spades"
      }
    ]
  end
  let(:community_cards) do
    [
      {
        "rank": "4",
        "suit": "spades"
      },
      {
        "rank": "A",
        "suit": "hearts"
      },
      {
        "rank": "6",
        "suit": "clubs"
      }
    ]
  end
  let(:another_player) do
    {
      "id": 2,
      "name": "Chuck",
      "status": "out",
      "version": "Default random player",
      "stack": 0,
      "bet": 0
    }
  end

  let(:game_state) do
    {
      "tournament_id": "550d1d68cd7bd10003000003",
      "game_id": "550da1cb2d909006e90004b1",
      "round": 0,
      "bet_index": 0,
      "small_blind": 10,
      "current_buy_in": current_buy_in,
      "pot": 400,
      "minimum_raise": 240,
      "dealer": 1,
      "orbits": 7,
      "in_action": 1,
      "players": [
        {
          "id": 0,
          "name": "Albert",
          "status": "active",
          "version": "Default random player",
          "stack": 1010,
          "bet": 320
        },
        {
          "id": 1,
          "name": "Bob",
          "status": "active",
          "version": "Default random player",
          "stack": 1590,
          "bet": 80,
          "hole_cards": hole_cards
        },
        another_player
      ],
      "community_cards": community_cards
    }.to_json
  end

  context 'no high card' do
    let(:hole_cards) do
      [
        {
          "rank": "6",
          "suit": "hearts"
        },
        {
          "rank": "10",
          "suit": "spades"
        }
      ]
    end

    it 'folds' do
      expect(player.bet_request).to eql 0
    end
  end

  context 'another player is too sure' do
    let(:another_player) do
      {
        "id": 2,
        "name": "Chuck",
        "status": "out",
        "version": "Default random player",
        "stack": 100,
        "bet": 500
      }
    end

    it 'folds' do
      expect(player.bet_request).to eql 0
    end
  end

  context 'has pair' do
    context 'lower' do
      let(:hole_cards) do
        [
          {
            "rank": "3",
            "suit": "hearts"
          },
          {
            "rank": "3",
            "suit": "spades"
          }
        ]
      end

      it 'raises 100 more than minimum_possible_raise' do
        expect(player.bet_request).to eql 393
      end
    end

    context 'higher' do
      let(:hole_cards) do
        [
          {
            "rank": "J",
            "suit": "hearts"
          },
          {
            "rank": "J",
            "suit": "clubs"
          }
        ]
      end

      it 'raises 100 more than minimum_possible_raise' do
        expect(player.bet_request.to_i).to eql 1042
      end
    end

    context 'double' do
      let(:hole_cards) do
        [
          {
            "rank": "6",
            "suit": "hearts"
          },
          {
            "rank": "4",
            "suit": "spades"
          }
        ]
      end

      it 'raises 1500 more than the minimum_possible_raise' do
        expect(player.bet_request).to eql 1590
      end
    end
  end

  context 'has 3 of a rank' do
    let(:hole_cards) do
      [
        {
          "rank": "6",
          "suit": "hearts"
        },
        {
          "rank": "6",
          "suit": "spades"
        }
      ]
    end

    it 'raises 2000 more than the minimum_possible_raise' do
      expect(player.bet_request).to eql 1590
    end
  end

  context 'flush availability' do
    let(:hole_cards) do
      [
        {
          "rank": "6",
          "suit": "clubs"
        },
        {
          "rank": "K",
          "suit": "clubs"
        }
      ]
    end

    context 'happened' do
      let(:community_cards) do
        [
          {
            "rank": "4",
            "suit": "clubs"
          },
          {
            "rank": "A",
            "suit": "clubs"
          },
          {
            "rank": "6",
            "suit": "clubs"
          }
        ]
      end

      it 'raises 2000 more than the minimum_possible_raise' do
        expect(player.bet_request).to eql 1590
      end
    end

    context 'still chance' do
      let(:community_cards) do
        []
      end

      it 'raises 1 more than the minimum_possible_raise' do
        expect(player.bet_request).to eql 261
      end
    end
  end
end
