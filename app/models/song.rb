# Columns not in use:
#   GIGID

class Song < ActiveRecord::Base
  self.table_name = "SONG"

  has_many :gigsets, foreign_key: "SONGID"
  has_many :gigs, through: :gigsets, foreign_key: "SONGID"

  has_one :track, foreign_key: "SONGID"
 
  belongs_to :album, foreign_key: "MAJRID"

  debugger

  def self.search_by(kind, search)

    case kind
      when :title
        column = "Song"
      when :lyrics
        column = "Lyrics"
      when :author
        column = "Author"
      else
        column = "Song"
    end 

    if search
      find(:all, :conditions => ["#{column} LIKE ?", "%#{search}%"])
    else
      find(:all)
    end
  end

end