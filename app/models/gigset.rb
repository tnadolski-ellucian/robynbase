class Gigset < ActiveRecord::Base
  self.table_name = "GSET"

  belongs_to :gig, foreign_key: "GIGID"
  belongs_to :song, foreign_key: "SONGID"

end