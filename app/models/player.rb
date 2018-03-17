class Player < ApplicationRecord
  has_one :career_stat
  has_many :similar_career_players, -> { where(age:nil) }, class_name: 'Player'
  has_many :similar_age_players, -> { where.not(age:nil).order(age: :asc) }, class_name: 'Player'
end
