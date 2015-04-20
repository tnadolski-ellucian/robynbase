class SongsController < ApplicationController

  def index

    if params[:search_type].present?
      @songs = Song.search_by(params[:search_type] ? params[:search_type].map {|type| type.to_sym} : nil, params[:song_search_value])
    else 
      params[:search_type] = "title"
    end

    @show_lyrics = (params[:search_type].size == 1 and params[:search_type].first == "lyrics")

  end

  def quick_query
    @songs = Song.quick_query(params[:query_id], params[:query_attribute])
    render "index"
  end

  def show

    @song = Song.find(params[:id])

    @gigs_present = @song.gigs.present?
    @albums_present = @song.compositions.present? 
    
  end

end