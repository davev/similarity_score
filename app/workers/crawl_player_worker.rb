class CrawlPlayerWorker
  include Sidekiq::Worker


  BASE_URL = "https://www.baseball-reference.com/players/"

  def perform(path = nil)
    return unless path

    url = URI.join(BASE_URL, path).to_s
    player_doc = Nokogiri::HTML(RestClient.get(url));

    raw_similarity_scores_comment = player_doc.xpath("//*[@id='all_ss_other']/comment()").to_s
    similarity_scores_html = raw_similarity_scores_comment.gsub("<!--","").gsub("-->","").gsub("\n", '')

    similarity_scores_doc = Nokogiri::HTML(similarity_scores_html)

    data_grid_boxes = similarity_scores_doc.xpath "//*[@id='ss_data_grid']/div[@class='data_grid_box']"

    data_grid_boxes.each do |data_grid|
      # puts 'hi' if (data_grid>("div[text()='Most Similar by Ages']")).present?
      puts data_grid>("div[text()]")
      puts data_grid>("ol/li")

    end

  end

  def persist_player_record

  end

  def persist_similar_player
  end

end
