# Columns not in use:
#   GIGID

class Song < ActiveRecord::Base
  self.table_name = "SONG"

  has_many :gigsets, foreign_key: "SONGID"
  has_many :gigs, through: :gigsets, foreign_key: "SONGID"

  has_many :tracks, foreign_key: "SONGID"
  has_many :compositions, through: :tracks, foreign_key: "SONGID"
 
  belongs_to :album, foreign_key: "MAJRID"

  # debugger

  def self.search_by(kind, search)

    kind = [:title, :lyrics, :author, :song] if kind.nil? or kind.length == 0

    conditions = Array(kind).map do |term|

      case term
        when :title
          column = "Song"
        when :lyrics
          column = "Lyrics"
        when :author
          column = "Author"
        else
          column = "Song"
      end

      "#{column} LIKE ?"

    end

    if search
      where(conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%"))
    else
      all
    end
  end

end   