class AboutController < ApplicationController

    def index
        @stats = {
            "song_count"   => Gig.get_distinct_song_performances,
            "gig_count"    => Gig.get_gig_count,
            "gigset_count" => Gig.get_gigset_count,
            "venue_count"  => Gig.get_distinct_venue_count
        }
    end
    
end
  