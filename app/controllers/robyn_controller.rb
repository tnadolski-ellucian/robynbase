class RobynController < ApplicationController

  def index

    search = params[:search_value] 

    logger.info "search: #{search}"

    if not search.nil? 
      @songs = Song.search_by [:title, :lyrics, :author], search
      @compositions = Composition.search_by [:title], search
      @gigs = Gig.search_by [:venue, :venue_city], search
    end
    
  end

  def search

    search = params[:search_value] 

    logger.info "search: #{search}"

    if not search.nil? 
      @songs = Song.search_by [:title], search
    end

    logger.info @songs

    render json: @songs

  end

  def search_gigs

    search = params[:search_value] 

    logger.info "gig search: #{search}"

    if not search.nil? 
      @gigs = Gig.search_by [:venue], search
    end

    logger.info "found gigs: #{@gigs}"

    render json: @gigs

  end

end
