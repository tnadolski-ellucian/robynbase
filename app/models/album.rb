class Album < ActiveRecord::Base
  self.table_name = "MAJR"

  has_many :songs, foreign_key: "MAJRID"
  

  def get_songs(album_id)
    Album.joins(:songs).where("majr.majrid = ?", album_id)
  end

end