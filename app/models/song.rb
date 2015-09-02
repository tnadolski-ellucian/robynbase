# Columns not in use:
#   GIGID

class Song < ActiveRecord::Base

  self.table_name = "SONG"

  has_many :gigsets, foreign_key: "SONGID"
  has_many :gigs, through: :gigsets, foreign_key: "SONGID"

  has_many :tracks, foreign_key: "SONGID"
  has_many :compositions, through: :tracks, foreign_key: "SONGID"
 
  belongs_to :album, foreign_key: "MAJRID"
  
  # set up the many-many relationship with the performance table
  has_many :song_performance
  has_many :performances, :through => :song_performance

  @@quick_queries = [ 
    QuickQuery.new('songs', :not_written_by_robyn),
    QuickQuery.new('songs', :never_released, [:originals, :covers]),
    QuickQuery.new('songs', :has_guitar_tabs, [:no_tabs]),
    QuickQuery.new('songs', :has_lyrics, [:no_lyrics]),
    QuickQuery.new('songs', :released_never_played_live)
  ]

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

  def get_albums
    self.compositions.order('Year').group('Title')
  end

  def full_name
    (self.Prefix.present? ? "#{self.Prefix} " : "") + self.Song
  end

  # returns an array of all available quick queries
  def self.get_quick_queries 
    @@quick_queries
  end

  # look up songs based on the given quick query
  def self.quick_query(id, secondary_attribute)

    case id
      when :not_written_by_robyn.to_s
        songs = get_songs_not_written_by_robyn()
      when :never_released.to_s        
        songs = quick_query_never_released(secondary_attribute)
      when :has_guitar_tabs.to_s
        songs = quick_query_guitar_tabs(secondary_attribute)
      when :has_lyrics.to_s
        songs = quick_query_lyrics(secondary_attribute)
      when :released_never_played_live.to_s
        songs = quick_query_released_no_live_performances
    end

    songs

  end


  ## ------ quick queries

  def self.get_songs_not_written_by_robyn 
    where("Author IS NOT NULL AND Author NOT LIKE '%Hitchcock%'")
  end

  def self.quick_query_never_released(secondary_attribute)

    # songs = joins(:compositions).distinct
    songs = Song.joins("LEFT OUTER JOIN TRAK ON SONG.songid = TRAK.songid").where("TRAK.songid IS NULL").distinct

    case secondary_attribute
      when "originals"
        songs = songs.where(:author => nil)
      when "covers"
        songs = songs.where.not(:author => nil)
    end

    songs

  end

  def self.quick_query_guitar_tabs(has_tabs)
    where("tab IS #{has_tabs.nil? ? 'NOT': ''} NULL")

  end

  def self.quick_query_lyrics(has_lyrics)
    where("lyrics IS #{has_lyrics.nil? ? 'NOT': ''} NULL")
  end

  def self.quick_query_released_no_live_performances
    joins("INNER JOIN TRAK ON SONG.songid = TRAK.songid").joins("LEFT OUTER JOIN GSET ON SONG.songid = GSET.songid").where("GSET.songid IS NULL").distinct
  end

end   