class Composition < ActiveRecord::Base

  self.table_name = "COMP"

  has_many :tracks, foreign_key: "COMPID"

  # types of media, and the order in which they should appear
  MEDIA_TYPES = {
    'CD'         => 0,
    'Vinyl LP'   => 1,
    'Vinyl 12"'  => 2,
    'Vinyl 7"'   => 3,
    'Cassette'   => 4,
    'CD 3"'      => 5,
    'CD Single'  => 6,
    'DVD'        => 7,
    'Fixel-disc' => 8,
    'Videotape'  => 9,
    'Other'      => 10
  }

  MEDIA_TYPES.default = 10;

  # types of releases, in the order in which they should appear
  RELEASE_TYPES = {
    'Authorized'       => 0,
    'Compilation'      => 1,
    'Promo'            => 2,
    'Radio show'       => 3,
    'Unauthorized'     => 4,
    'Internet'         => 5,
    'Fan Club release' => 6,
    'Compilation'      => 7,
    'Other'            => 8
  }

  RELEASE_TYPES.default = 8;
    

  def self.search_by(kind, search, media_types, release_types)

    kind = [:title, :release_year, :label] if kind.nil? or kind.length == 0

    conditions = Array(kind).map do |term|

      case term 
        when :title
          column = "Title"
        when :release_year
          column = "Year"
        when :label
          column = "Label"
      end

      "#{column} LIKE ?"

    end

    if search.present? or media_types.present? or release_types.present?

      # grab albums according to the given search type/value
      albums = where(conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%"))

      # filter by media type
      if media_types.present?
        albums = albums.where(Medium: MEDIA_TYPES.select {|name, key| media_types.include?(key)}.keys )
      end

      # filter by release type
      if release_types.present?
        albums = albums.where(Type: RELEASE_TYPES.select {|name, key| release_types.include?(key)}.keys )        
      end

      # ordering by year, grouping by title to eliminate duplicates
      albums.order("Year").group("Title")

    else
      all

    end

  end 

end