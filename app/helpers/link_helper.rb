module LinkHelper

  def link_to_baseball_reference_player(player, text = "view full stats")
    return unless player

    url = URI.join(ENV.fetch('BASEBALL_REFERENCE_URL'), player.handle).to_s
    link_to text, url
  end

  def link_to_baseball_reference(text = 'baseball-reference.com')
    link_to text, 'https://www.baseball-reference.com'
  end

  def link_to_similarity_scores_description(text = 'Similarity Scores')
    link_to text, 'https://www.baseball-reference.com/about/similarity.shtml'
  end

  def link_to_bill_james(text = 'Bill James')
    link_to text, 'https://en.wikipedia.org/wiki/Bill_James'
  end

  def link_to_trigram(text = 'trigram')
    link_to text, 'https://about.gitlab.com/2016/03/18/fast-search-using-postgresql-trigram-indexes/'
  end

  def link_to_random_player(text = 'random player')
    link_to text, random_players_path, data: { turbolinks: 'false' }
  end

end
