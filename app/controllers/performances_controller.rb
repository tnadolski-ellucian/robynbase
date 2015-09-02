class PerformancesController < ApplicationController

  def index

    search_type_param  = params[:search_type]
    media_param   = params[:media]
    performance_type_param = params[:performance_type]

    if params[:search_type].present?

      # textual search
      search_type = search_type_param ? search_type_param.map {|type| type.to_sym} : nil

      # media
      media = media_param.map {|type| type.to_i} if media_param.present?

      # performance types
      performance_types = performance_type_param.map {|type| type.to_i} if performance_type_param.present?

      @performances = Performance.search_by(search_type, params[:performance_search_value], media, performance_types)

    else 

      params[:search_type] = "name"

    end

    # @show_lyrics = (params[:search_type].size == 1 and params[:search_type].first == "lyrics")

  end

  def show
    @performance = Performance.find(params[:id])    
  end

  def quick_query
    # @songs = Performance.quick_query(params[:query_id], params[:query_attribute])
    # render "index"
  end

end
