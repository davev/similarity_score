class SimilarPlayer < ApplicationRecord
  belongs_to :player
  belongs_to :related_player, class_name: 'Player'
end
