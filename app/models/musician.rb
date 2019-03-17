class Musician < ApplicationRecord
  self.table_name = "MUSO"

  belongs_to :songs, foreign_key: "MUSOID"
  
end