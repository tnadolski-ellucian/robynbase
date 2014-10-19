# Columns not in use:
#   StartTime  (only 3  records, all invalid dates)
#   Performance
#   Sound
#   Rarity



class Gig < ActiveRecord::Base
  self.table_name = "GIG"

  has_many :gigsets, foreign_key: "GIGID"
  has_many :songs, through: :gigsets, foreign_key: "GIGID"
  has_one :venue, foreign_key: "VENUEID"

  def self.search_by(kind, search)

    logger.info ("::::::::::: gigs: #{search}")

    kind = [:venue, :gig_year, :venue_city] if kind.nil? or kind.length == 0

    conditions = Array(kind).reject{|x| x == :venue_city}.map do |term|

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
      gigs = find(:all, :conditions => [conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%")])


      if kind.include? :venue_city
        venues = self.joins(:venue).where("City LIKE '%#{search}%'")

        if not venues.nil? 
          gigs.concat(venues)
        end
      end

      gigs

    else
      all
    end

  end

end