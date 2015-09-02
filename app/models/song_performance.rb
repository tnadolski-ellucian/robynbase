class SongPerformance < ActiveRecord::Base
  belongs_to :song
  belongs_to :performance
end
