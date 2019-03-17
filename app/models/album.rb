class Album < ApplicationRecord
  self.table_name = "MAJR"

  has_many :songs, foreign_key: "MAJRID"
  

  def get_songs(album_id)
    Album.joins(:songs).where("majr.majrid = ?", album_id)
  end

  # TODO: do we actually need this?
  def self.search_by(kind, search)

    kind = [:title, :recorded_by, :release_year] if kind.nil? or kind.length == 0

    conditions = Array(kind).map do |term|

      case term 
        when :title
          column = "AlbumTitles"
        when :recorded_by
          column = "RecordedBy"
        when :release_year
          column = "ReleaseYear"
        else
          column = "AlbumTitles"
      end

      "#{column} LIKE ?"

    end

    if search
      find(:all, :conditions => [conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%")])
    else
      all
    end
  end 
  
end