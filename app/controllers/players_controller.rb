class PlayersController < ApplicationController

  def index
    @player = Player.find_by(name: 'Ernie Banks')
    @similar_career_players = @player.similar_career_players.includes(:related_player)


    if (@query = params[:q]).present?
      @suggestions = Player.where("name ILIKE concat('%', ?, '%')", @query).order("name")
      render json: @suggestions
    end

  end

  def show
  end

end
