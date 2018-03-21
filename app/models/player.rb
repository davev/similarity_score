class Player < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_one :career_stat
  has_many :similar_career_players, -> { where(age:nil).order(score: :desc) }, class_name: 'SimilarPlayer', dependent: :destroy
  has_many :similar_age_players, -> { where.not(age:nil).order(age: :asc, score: :desc) }, class_name: 'SimilarPlayer', dependent: :destroy

  scope :scraped, -> { where.not(active_year_begin: nil) }

  def scraped?
    active_year_begin.present?
  end

  def as_json(options={})
    {
      id: id,
      slug: slug,
      name: name
    }
  end
end
