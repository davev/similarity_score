class CrawlPlayerIndexWorker
  include Sidekiq::Worker


  BASE_URL = ENV.fetch('BASEBALL_REFERENCE_URL')


  def perform
    ('a'..'z').each do |letter|
      sleep(5) # throttle to be a good citizen of server
      url = URI.join(BASE_URL, "players/#{letter}").to_s
      doc = Nokogiri::HTML(RestClient.get(url))
      players = doc.css("#div_players_ a")
      players.each do |player|
        CrawlPlayerWorker.perform_async(player.attr("href"))
      end
    end
  end

end
