class Player < ApplicationRecord
  has_one :career_stat
  has_many :similar_career_players, -> { where(age:nil).order(score: :desc) }, class_name: 'SimilarPlayer'
  has_many :similar_age_players, -> { where.not(age:nil).order(age: :asc, score: :desc) }, class_name: 'SimilarPlayer'
end
