class SongsController < ApplicationController

  authorize_resource :only => [:new, :edit, :update]

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

  # Prepare song create page
  def new
    @song = Song.new
  end

  # Prepare song update page
  def edit 
    @song = Song.find(params[:id])
  end
    
  # Update exisiting song
  def update 
    
    song = Song.find(params[:id])
    
    filtered_params = song_params()
    
    # extract the article prefix (if any) from song name
    (prefix, song_name) = Song.parse_song_name(filtered_params[:full_name])
    
    # store prefix and the rest of the song name separately
    filtered_params[:Song] = song_name
    filtered_params[:Prefix] = prefix
    filtered_params.delete(:full_name)
    
    # if no author specified, store a null
    filtered_params[:Author] = nil if filtered_params[:Author].strip.empty?

    song.update!(filtered_params)
    
    redirect_to song
    
  end

  # Create a new song
  def create

    filtered_params = song_params()
        
    # extract the article prefix (if any) from song name
    (prefix, song_name) = Song.parse_song_name(filtered_params[:full_name])

    # store prefix and the rest of the song name separately
    filtered_params[:Song] = song_name
    filtered_params[:Prefix] = prefix
    filtered_params.delete(:full_name)

    # if no author specified, store a null
    filtered_params[:Author] = nil if filtered_params[:Author].strip.empty?

    @song = Song.new(filtered_params)

    if @song.save
      redirect_to @song
    else
      # This line overrides the default rendering behavior, which
      # would have been to render the "create" view.
      render "new"
    end

  end

  # Remove song
  def destroy
    song = Song.find(params[:id])
    song.destroy

    redirect_back fallback_location: songs_url

  end
  
  def show

    @song = Song.find(params[:id])

    @gigs_present = @song.gigs.present?
    @albums_present = @song.compositions.present? 
    
  end
  
  
  private
  
    def song_params
      params.require(:song).permit(:full_name, :Author, :OrigBand, :Improvised, :Lyrics, :Comments).tap do |params|
        params.require(:full_name)
      end
    end

end