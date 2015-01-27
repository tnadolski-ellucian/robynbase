class GigsController < ApplicationController

  def index

    if params[:search_type].present?
      @gigs = Gig.search_by(params[:search_type] ? params[:search_type].map {|type| type.to_sym} : nil, params[:search_value])
    end

  end

  def show
    @gig = Gig.find(params[:id])
  end

end
