class RobynController < ApplicationController
  def index
    @songs = Song.search_by(params[:search_type] ? params[:search_type].to_sym : nil, params[:search_value])
  end

  def search_songs
  end

end
