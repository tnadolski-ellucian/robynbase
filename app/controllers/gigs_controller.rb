class GigsController < ApplicationController

  def index
  end

  def show
    @gig = Gig.find(params[:id])
  end

end
