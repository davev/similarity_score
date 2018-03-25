class RecrawlCurrentPlayersWorker
  include Sidekiq::Worker


  BASE_URL = ENV.fetch('BASEBALL_REFERENCE_URL')

  # see CrawlPlayerWorker for default opts values, e.g.
  #   recursive: true, force_player: false, force_stats: false, force_similar: false
  def perform(opts = {})
    opts = opts.with_indifferent_access.reverse_merge({
      recursive: false
    })

    Player.where("active_year_end >= 2017").find_each(batch_size: 200) do |player|
      CrawlPlayerWorker.perform_async(player.handle, opts)
    end
  end

end
