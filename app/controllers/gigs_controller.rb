class GigsController < ApplicationController

  def index

    if params[:search_type].present?
      @gigs = Gig.search_by(params[:search_type] ? params[:search_type].map {|type| type.to_sym} : nil, params[:search_value])
    else
      params[:search_type] = "venue"
    end

  end

  def show
    @gig = Gig.find(params[:id])
  end

end
