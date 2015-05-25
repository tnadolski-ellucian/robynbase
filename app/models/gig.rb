# Columns not in use:
#   StartTime  (only 3  records, all invalid dates)
#   Performance
#   Sound
#   Rarity


class Gig < ActiveRecord::Base

  self.table_name = "GIG"

  has_many :gigsets, -> {order 'Chrono'}, foreign_key: "GIGID"
  has_many :songs, through: :gigsets, foreign_key: "GIGID"
  belongs_to :venue, foreign_key: "VENUEID"

  @@quick_queries = [ 
    QuickQuery.new('gigs', :with_setlists, [:without]),
    QuickQuery.new('gigs', :without_definite_dates),
    QuickQuery.new('gigs', :with_reviews, [:without])
  ]

  # returns the songs played in the gig (non-encore)
  def get_set
    self.gigsets.includes(:song).where(encore: false)
  end

  # returns the reviews for this gig (if any), formatted to display correctly in html
  def get_reviews
    if self.Reviews.present?
      self.Reviews.gsub(/\r\n/, '<br>')
    end
  end

  # returns the songs played in the encore
  def get_set_encore
    self.gigsets.includes(:song).where(encore: true)
  end

  def self.search_by(kind, search, date_criteria = nil)

    logger.info ("::::::::::: gigs: #{search}")

    kind = [:venue, :gig_year, :venue_city] if kind.nil? or kind.length == 0

    conditions = Array(kind).reject{|x| x == :venue_city || x == :venue_state}.map do |term|

      case term
        when :venue
          column = "Venue"
        when :gig_year
          column = "GigYear"
        else
          return false
      end

      "#{column} LIKE ?"

    end

    if search

      gigs = where(conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%"))

      if kind.include? :venue_city
        gigs = self.joins(:venue).where("City LIKE ?", search)
      end

      if kind.include? :venue_state
        gigs = self.joins(:venue).where("State LIKE ?", search)
      end

      if date_criteria.present?
        date = date_criteria[:date]
        range_type = date_criteria[:range_type]
        range = date_criteria[:range]

        # debugger
        
        gigs = gigs.where(:gigdate => date.advance(range_type => -range) .. date.advance(range_type => range))

      end

      # sort final results by date
      gigs.includes(:venue).sort { |x,y | x.GigDate <=> y.GigDate }

    else
      all
    end

  end


  # an array of all available quick queries
  def self.get_quick_queries 
    @@quick_queries
  end

  # look up songs based on the given quick query
  def self.quick_query(id, secondary_attribute)

    case id
      when :with_setlists.to_s
        gigs = quick_query_gigs_with_setlists(secondary_attribute)
      when :without_definite_dates.to_s
        gigs = quick_query_gigs_without_definite_dates
      when :with_reviews.to_s
        gigs = quick_query_gigs_with_reviews(secondary_attribute)
    end

    gigs.where.not(:venue => nil)

  end


  ## quick queries

  def self.quick_query_gigs_with_setlists(secondary_attribute)
    joins("LEFT OUTER JOIN GSET on GIG.gigid = GSET.gigid").where("GSET.setid IS #{secondary_attribute.nil? ? 'NOT' : ''} NULL").distinct    
  end

  def self.quick_query_gigs_without_definite_dates
    where(:circa => 1)
  end

  def self.quick_query_gigs_with_reviews(no_reviews)
    where("Reviews IS #{no_reviews.nil? ? 'NOT' : ''} NULL")
  end

end