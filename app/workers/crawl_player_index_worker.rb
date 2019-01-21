class CrawlPlayerIndexWorker
  include Sidekiq::Worker


  BASE_URL = ENV.fetch('BASEBALL_REFERENCE_URL')


  def perform
    ('a'..'z').each do |letter|
      sleep(20) # throttle to be a good citizen of server
      url = URI.join(BASE_URL, "players/#{letter}").to_s
      doc = Nokogiri::HTML(RestClient.get(url))
      players = doc.css("#div_players_ a")
      players.each do |player|
        # opts and their default values:
        # recursive: true,
        # force_player: false,
        # force_stats: false,
        # force_similar: false
        CrawlPlayerWorker.perform_async(player.attr("href"), recursive: false, force_player: true, force_stats: true, force_similar: true)
      end
    end
  end

end
