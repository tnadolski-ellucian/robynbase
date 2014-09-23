class Track < ActiveRecord::Base
  self.table_name = "TRAK"

  belongs_to :composition, foreign_key: "COMPID"

end