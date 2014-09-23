# Columns not in use:
#   StartTime  (only 3  records, all invalid dates)
#   Performance
#   Sound
#   Rarity



class Gig < ActiveRecord::Base
  self.table_name = "GIG"

  has_many :gigsets, foreign_key: "GIGID"
  has_many :songs, through: :gigsets, foreign_key: "GIGID"
  has_one :venue, foreign_key: "VENUEID"

end