class SongsController < ApplicationController
  def index

  if params[:search_type].present?
    @songs = Song.search_by(params[:search_type] ? params[:search_type].map {|type| type.to_sym} : nil, params[:search_value])
  end

  end

  def show
    @song = Song.find(params[:id])
  end
  
end