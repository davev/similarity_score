class CrawlPlayerWorker
  include Sidekiq::Worker


  BASE_URL = "https://www.baseball-reference.com/"

  # attr_reader :path
  attr_accessor :path

  def perform(path = nil)
    return unless @path = path

    persist_player
    persist_player_career_stats
    persist_similar_players
  end

  def doc
    player_doc
  end

  private

  def url
    @url ||= URI.join(BASE_URL, path).to_s
  end

  def player_doc
    @player_doc ||= Nokogiri::HTML(RestClient.get(url))
  end

  def player_model
    @player_model ||= Player.find_or_initialize_by(handle: path)
  end

  def persist_player
    name_node = player_doc.css("#meta h1[itemprop='name']")
    image_node = player_doc.css("#meta > div.media-item > img:first")
    active_year_doc = comments_content("//*[@id='all_appearances']")

    return if player_model.active_year_begin.present? # already processed this player

    player_model.update_attributes(
      name: name_node.text,
      image: image_node.attr("src").value,
      active_year_begin: active_year_doc.css("table#appearances tbody tr:first th").text,
      active_year_end: active_year_doc.css("table#appearances tbody tr:last th").text,
      hof: player_doc.css("ul#bling li.bling_hof").any?
    )
  end

  # TODO
  def persist_player_career_stats
    return if player_model.career_stat.present?
  end

  def persist_similar_players
    return if player_model.similar_career_players.any?

    similarity_scores_doc = comments_content("//*[@id='all_ss_other']")

    data_grid_boxes = similarity_scores_doc.xpath "//*[@id='ss_data_grid']/div[@class='data_grid_box']"

    data_grid_boxes.each do |data_grid|
      data_grid_type = data_grid.css("div.gridtitle").text

      case data_grid_type.downcase
      when "similar pitchers"
        save_career_similars(data_grid)
      when "similar batters"
        save_career_similars(data_grid)
      when "most similar by ages"
        save_age_similars(data_grid)
      end
    end
  end


  def save_career_similars(grid)
    players = grid.css("ol li")
    players.each do |player|
      name = player.children.first.text
      handle = player.children.first.attr("href")

      raw_score_text = player.children.last.text
      score_regex = /([0-9.]+)/
      score = score_regex.match(raw_score_text).captures.last
      hof = raw_score_text.strip.include? '*'

      related_player = Player.find_or_initialize_by(handle: handle)
      related_player.update_attributes(name: name, hof: hof)

      similar_player = SimilarPlayer.find_or_initialize_by(
        player_id: player_model.id,
        related_player_id: related_player.id,
      )
      similar_player.assign_attributes(score: score)
      similar_player.save

      CrawlPlayerWorker.perform_async(handle)
    end
  end

  # TODO
  def save_age_similars(grid)

    # CrawlPlayerWorker.perform_async(handle)
  end

  # some baseball-reference table content is hidden in comments and then splatted into page with JS.  this method grabs the comments and extracts the html structure as a Nokogiri document
  def comments_content(path)
    raw_comments = player_doc.xpath("#{path}/comment()").to_s
    html = raw_comments.gsub("<!--","").gsub("-->","").gsub("\n", '')

    doc = Nokogiri::HTML(html)
  end
end
