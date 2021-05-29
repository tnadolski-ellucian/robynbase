# Columns not in use:
#   StartTime  (only 3  records, all invalid dates)
#   Performance
#   Sound
#   Rarity


class Gig < ApplicationRecord

  self.table_name = "GIG"

  has_many :gigsets, -> {order 'Chrono'}, foreign_key: "GIGID", dependent: :delete_all
  has_many :songs, through: :gigsets, foreign_key: "GIGID"
  belongs_to :venue, foreign_key: "VENUEID"

  accepts_nested_attributes_for :gigsets

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

    # add conditions for the gig table columns
    conditions = Array(kind).map do |term|

      case term
        when :venue
          column = "Venue"
        when :gig_year
          column = "GigYear"
        when :venue_city
          column = "VENUE.City"
        when :venue_state
          column = "VENUE.State"
        when :venue_country
          column = "VENUE.Country"
        else
          return false
      end

      "#{column} LIKE ?"

    end

    if search

      gigs = left_outer_joins(:venue).where(conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%"))

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
    if (no_reviews.nil?)
      where("Reviews IS NOT NULL AND Reviews <> ''")
    else 
      where("Reviews IS NULL OR Reviews = ''")
    end
  end

end