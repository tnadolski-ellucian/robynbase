class SongsController < ApplicationController
  def index

    @songs = Song.search_by(params[:search_type] ? params[:search_type].map {|type| type.to_sym} : nil, params[:search_value])

  end

  def show
    @song = Song.find(params[:id])
  end
  
end
