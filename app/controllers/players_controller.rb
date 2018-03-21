class PlayersController < ApplicationController

  def index
    @player = Player.find_by(name: 'Ernie Banks')
    @players = @player.similar_career_players
    @suggestions = Player.where("name ILIKE '%mat%'").order("name")
  end

  def show
  end
end
