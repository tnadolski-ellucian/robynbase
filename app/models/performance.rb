class Performance < ApplicationRecord

  self.primary_key = "performanceid"

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

    kind = [:name] if kind.nil? or kind.length == 0
    
    # grab conditions for all "simple" criteria -- ie criteria that are local to the model, and don't require joins
    conditions = Array(kind).map do |term|

      case term

        when :name
          column = "name"

      end

      if column.present?
        "#{column} LIKE ?" 
      end

    end.reject { |item| item.nil? }

    performances = Performance.all
    
    if not search.empty?

      # do the appropriate joins to search by song name
      if kind.include? :song
        performances = performances.joins("INNER JOIN song_performances ON song_performances.performance_id = performances.performanceid INNER JOIN song ON song_performances.song_id = song.songid WHERE song.song LIKE '%#{search}%'")
      end

      # clauses for simple search criteria
      if not conditions.empty?
        performances = performances.where(conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%"))
      end

      # filter by media
      if media.present?
        performances = performances.where( Medium: media )
      end

      # filter by performance type
      if performance_types.present?
        performances = performances.where(performance_type: performance_types)
      end

    end

    performances

  end

  # returns an array of all available quick queries
  def self.get_quick_queries 
    # @@quick_queries
  end

end
