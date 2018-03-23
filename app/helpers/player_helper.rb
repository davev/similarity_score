module PlayerHelper

  def active_years(player)
    return unless player
    "#{player.active_year_begin} - #{player.active_year_end}"
  end

  def link_to_baseball_reference(player, text = "view full stats")
    return unless player

    url = URI.join(ENV.fetch('BASEBALL_REFERENCE_URL'), player.handle).to_s
    link_to text, url
  end
end
