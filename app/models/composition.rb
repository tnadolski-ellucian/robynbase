class Composition < ActiveRecord::Base
  self.table_name = "COMP"

  has_many :tracks, foreign_key: "COMPID"

end