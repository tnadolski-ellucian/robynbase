class VenuesController < ApplicationController

  def index
  end
  
  def show
    @venue = Venue.find(params[:id])
  end

end
