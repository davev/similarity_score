class CrawlPlayerWorker
  include Sidekiq::Worker


  BASE_URL = ENV.fetch('BASEBALL_REFERENCE_URL')

  attr_reader :path

  def perform(path, opts={})
    return unless @path = path

    @opts = opts.with_indifferent_access.reverse_merge({
      recursive: true,
      force_player: false,
      force_stats: false,
      force_similar: false
    })

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
      sleep(rand(2.0...5.0)) # be a good citizen of server
      Nokogiri::HTML(RestClient.get(url))
    end
  end

  def player_model
    @player_model ||= Player.find_or_initialize_by(handle: path)
  end

  def persist_player
    return if player_model.scraped? && !@opts[:force_player] # already processed this player

    name_node = player_doc.css("#meta h1[itemprop='name']")
    image_node = player_doc.css("#meta > div.media-item > img:first")
    active_year_doc = comments_content("//*[@id='all_appearances']")

    player_model.assign_attributes(
      name: name_node.text,
      image: image_node.presence&.attr("src")&.value,
      active_year_begin: active_year_doc.css("table#appearances tbody tr:first th").text,
      active_year_end: active_year_doc.css("table#appearances tbody tr:last th").text,
      hof: player_doc.css("ul#bling li.bling_hof").any?
    )

    player_model.save
  end

  def persist_player_career_stats
    return if player_model.career_stat.present? && !@opts[:force_stats]

    career_stat = player_model.build_career_stat(
      war: career_stat_content("war").presence&.to_f&.round(1),

      # hitting
      ab: career_stat_content("ab").presence&.to_i,
      r: career_stat_content("r").presence&.to_i,
      h: career_stat_content("h").presence&.to_i,
      ba: career_stat_content("ba").presence&.to_f,
      hr: career_stat_content("hr").presence&.to_i,
      rbi: career_stat_content("rbi").presence&.to_i,
      obp: career_stat_content("obp").presence&.to_f,
      slg: career_stat_content("slg").presence&.to_f,
      ops: career_stat_content("ops").presence&.to_f,
      ops_plus: career_stat_content("ops+").presence,

      # pitching
      w: career_stat_content("w").presence&.to_i,
      l: career_stat_content("l").presence&.to_i,
      era: career_stat_content("era").presence&.to_f,
      g: career_stat_content("g").presence&.to_i,
      ip: career_stat_content("ip").presence&.to_f,
      so: career_stat_content("so").presence&.to_i,
      whip: career_stat_content("whip").presence&.to_f
    )
    career_stat.save
  end



  def persist_similar_players
    return if player_model.similar_career_players.any? && !@opts[:force_similar]

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
      #   of the form: <a href="/players/s/suareeu01.shtml" class="poptip" data-tip="2. Eugenio Suarez (959.9) ">2</a>
      handle = player_node.children.first.children.last.attr("href")
      return unless handle
      return if handle.include? "comparison.cgi" # skip last link in list for comparing multiple players

      str = player_node.children.last.children.last.attr("data-tip")
      regex = /\d+\.\s(?<name>[\w\s\.'"-]+)\s\((?<score>[\d\.]+)\)/
      m = regex.match(str)

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
    return unless @opts[:recursive]

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

  def career_stat_content(stat)
    player_doc.xpath("//*[@id='info']/div[@class='stats_pullout']//*[@class='poptip'][text()='#{stat.upcase}']/../p").text
  end
end
