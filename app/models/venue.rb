# what is NameSearch column for?
# Not used:
#   TaperFriendly
class Venue < ActiveRecord::Base
  self.table_name = "VENUE"

  def gigs
    Gig.where("VENUEID = %", self.VENUEID)
  end

end