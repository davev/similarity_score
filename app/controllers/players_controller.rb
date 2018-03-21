class PlayersController < ApplicationController

  def index
    return unless @query = params[:q]

    if @query.length <= 2
      # only search hof'ers
      @suggestions = Player.where(hof: true).where("name ILIKE concat('%', ?, '%')", @query)
    else
      # search everyone
      @suggestions = Player.where("name ILIKE concat('%', ?, '%')", @query)
    end

    @suggestions = @suggestions.limit(200).order(:name)

    render json: @suggestions

  end

  def show
    @player = Player.find_by(name: 'Ernie Banks')
    @similar_career_players = @player.similar_career_players.includes(:related_player)
  end

end
