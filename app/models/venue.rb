# what is NameSearch column for?
# Not used:
#   TaperFriendly
class Venue < ApplicationRecord
  self.table_name = "VENUE"

  has_many :gigs, foreign_key: "VENUEID"

  def self.search_by(kind, search)

    kind = [:name, :city, :country] if kind.nil? or kind.length == 0

    conditions = Array(kind).map do |term|

      case term
        when :name
          column = "Name"
        when :city
          column = "City"
        when :country
          column = "Country"
        when :state
          column = "State"
        when :subcity
          column = "SubCity"
        else
          column = "Name"
      end

      "#{column} LIKE ?"

    end

    if search
      venues = where(conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%"))
    else
      venues = all
    end

    venues.order(:Name => :asc)

  end

end