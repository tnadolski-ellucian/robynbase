class SongPerformance < ApplicationRecord
  belongs_to :song
  belongs_to :performance
end
