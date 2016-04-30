require 'sinatra'
require 'json'
require_relative 'player'

set :port, 8090
set :bind, '0.0.0.0'

post "/" do
  if params[:action] == 'bet_request'
    Player.new(params[:game_state]).bet_request.to_s
  elsif params[:action] == 'showdown'
    Player.new(params[:game_state]).showdown
    'OK'
  elsif params[:action] == 'version'
    Player::VERSION
  else
    'OK'
  end
end
