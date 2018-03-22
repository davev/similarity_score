module PlayerHelper

  def active_years(player)
    return unless player
    "#{player.active_year_begin} - #{player.active_year_end}"
  end

end
