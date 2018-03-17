class CrawlSimilarityScoresWorker
  include Sidekiq::Worker


  BASE_URL = "https://www.baseball-reference.com/players/"

  # babe ruth is default starting point
  def perform(path: 'r/ruthba01.shtml')
    url = URI.join(BASE_URL, path).to_s


  end
end
