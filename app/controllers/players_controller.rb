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
    @player = Player.find(params[:id])

  rescue ActiveRecord::RecordNotFound => exception
    redirect_to players_path, notice: 'Player not found.'
  end

  def random
    player = Player.limit(1).order("RANDOM()").first
    redirect_to player, notice: 'hello world' and return
  end

end
