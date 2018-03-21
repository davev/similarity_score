class PlayersController < ApplicationController

  def index
    if (@query = params[:q]).present?
      @suggestions = Player.where("name ILIKE concat('%', ?, '%')", @query).order("name").limit(100)
      render json: @suggestions
    end

  end

  def show
    @player = Player.find_by(name: 'Ernie Banks')
    @similar_career_players = @player.similar_career_players.includes(:related_player)
  end

end
