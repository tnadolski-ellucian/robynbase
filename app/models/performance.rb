class Performance < ActiveRecord::Base

  MEDIUM = {
    'Audio' => 1,
    'Video' => 2,
  }

  PERFORMANCE_TYPE = {
    'Concert' => 1,
    'TV' => 2,
    'Radio' => 3
  }

  HOST = {
    'archive.org' => 1,
    'youtube' => 2
  }

  # set up the many-many relationship with the songs table
  has_many :song_performance
  has_many :songs, :through => :song_performance


  def self.search_by(kind, search, media = nil, performance_types = nil)

    kind = [:name, :performance_type, :medium] if kind.nil? or kind.length == 0

    conditions = Array(kind).map do |term|

      case term
        when :name
          column = "name"
        when :venue
          column = "venue"
        else
          column = "name"
      end

      "#{column} LIKE ?"

    end
    
    if search
      performances = where(conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%"))

      # filter by media
      if media.present?
        performances = performances.where( Medium: media )
      end

      # filter by performance type
      if performance_types.present?
        performances = performances.where(performance_type: performance_types)
      end

      performances

    else
      all
    end
  end

  # returns an array of all available quick queries
  def self.get_quick_queries 
    # @@quick_queries
  end

end
