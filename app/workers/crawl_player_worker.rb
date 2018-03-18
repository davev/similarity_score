class CrawlPlayerWorker
  include Sidekiq::Worker


  BASE_URL = "https://www.baseball-reference.com/"

  attr_reader :path

  def perform(path = nil)
    return unless @path = path
    return if player_model.scraped?

    persist_player
    persist_player_career_stats
    persist_similar_players
  end

  # for debugging
  # def doc
  #   player_doc
  # end

  private

  def url
    @url ||= URI.join(BASE_URL, path).to_s
  end

  def player_doc
    @player_doc ||= begin
      sleep(rand(1.0...3.0)) # be a good citizen of server
      Nokogiri::HTML(RestClient.get(url))
    end
  end

  def player_model
    @player_model ||= Player.find_or_initialize_by(handle: path)
  end

  def persist_player
    return if player_model.scraped? # already processed this player

    name_node = player_doc.css("#meta h1[itemprop='name']")
    image_node = player_doc.css("#meta > div.media-item > img:first")
    active_year_doc = comments_content("//*[@id='all_appearances']")

    player_model.assign_attributes(
      name: name_node.text,
      image: image_node.attr("src").value,
      active_year_begin: active_year_doc.css("table#appearances tbody tr:first th").text,
      active_year_end: active_year_doc.css("table#appearances tbody tr:last th").text,
      hof: player_doc.css("ul#bling li.bling_hof").any?
    )

    player_model.save
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
    handles = []
    players = grid.css("ol li")
    players.each do |player|
      handles << save_similar_player(player.children.to_s.strip)
    end

    spawn_jobs(handles)
  end

  def save_age_similars(grid)
    handles = []
    age_lists = grid.css("ol li")
    age_lists.each do |age_list|
      age = age_list.attr("value").to_i
      next if age.zero?

      # byebug
      # players = age_list.css("a")
      players = age_list.children.to_s.strip.split(/\s{3,}/)
      players.each do |player_html|
        handles << save_similar_player(player_html, age: age)
      end
    end

    spawn_jobs(handles)
  end

  def save_similar_player(player_html, age: nil)
    return unless player_html
    handle = nil

    player_node = Nokogiri::HTML(player_html).children.last.children.first

    if player_html.include? "data-tip"
      # similar by age, 2-10
      #   of the form: <a href=\"/players/s/suareeu01.shtml\" class=\"poptip\" data-tip=\"2. Eugenio Suarez (959.9) \">2</a>
      handle = player_node.children.first.children.last.attr("href")
      return unless handle
      return if handle.include? "comparison.cgi" # skip last link in list for comparing multiple players

      str = player_node.children.last.children.last.attr("data-tip")
      regex = /\d+\.\s(?<name>[\w\s\.'"-]+)\s\((?<score>[\d\.]+)\)/
      m = regex.match(str)

      byebug
      name = m[:name]
      score = m[:score]
      hof = str.strip.include? '*'

    else
      # of the form: <a href="/players/m/mayswi01.shtml">Willie Mays</a> (782.1) *
      handle = player_node.children.first.attr("href")
      name = player_node.children.first.text

      raw_score_text = player_node.children.last.text
      score_regex = /([0-9\.]+)/
      score = score_regex.match(raw_score_text).captures.last
      hof = raw_score_text.strip.include? '*'
    end

    related_player = Player.find_or_initialize_by(handle: handle)
    related_player.assign_attributes(name: name, hof: hof)
    related_player.save

    similar_player = SimilarPlayer.find_or_initialize_by(
      player_id: player_model.id,
      related_player_id: related_player.id,
      age: age
    )
    similar_player.assign_attributes(score: score)
    similar_player.save

    return handle
  end

  def spawn_jobs(handles)
    handles.compact.uniq.each do |handle|
      player = Player.find_by(handle: handle)
      next if player.try(:scraped?) # optimization to skip records already in the system

      CrawlPlayerWorker.perform_async(handle)
    end
  end

  # some baseball-reference table content is hidden in comments and then splatted into page with JS.  this method grabs the comments and extracts the html structure as a Nokogiri document
  def comments_content(path)
    raw_comments = player_doc.xpath("#{path}/comment()").to_s
    html = raw_comments.gsub("<!--","").gsub("-->","").gsub("\n", '')

    doc = Nokogiri::HTML(html)
  end
end
