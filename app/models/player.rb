class Player < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_one :career_stat
  has_many :similar_careers, -> { includes(:related_player).where(age: nil).order(score: :desc) }, class_name: 'SimilarPlayer', dependent: :destroy
  has_many :similar_ages, -> { includes(:related_player).where.not(age: nil).order(age: :asc, score: :desc) }, class_name: 'SimilarPlayer', dependent: :destroy

  # has_many :similar_career_players, through: :similar_careers, source: :related_player
  # has_many :similar_age_players, through: :similar_ages, source: :related_player

  scope :scraped, -> { where.not(active_year_begin: nil) }
  scope :random, -> (count) { order(:random).limit(1) }


  def similar_age_years
    similar_ages.pluck(:age).uniq.sort
  end

  def similar_career_players
    @similar_career_players ||= similar_careers.collect(&:related_player)
  end

  def similar_age_players
    @similar_age_players ||= similar_ages.collect(&:related_player)
  end

  def scraped?
    active_year_begin.present?
  end

  def as_json(options={})
    super.slice("id", "name", "slug", "active_year_begin", "active_year_end", "hof")
  end

end
