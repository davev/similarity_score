class SimilarPlayer < ApplicationRecord
  belongs_to :player

  enum status: { batter: 0, pitcher: 1 }
end
