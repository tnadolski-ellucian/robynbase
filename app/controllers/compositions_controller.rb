class CompositionsController < ApplicationController

  def index

    # if the user entered any search terms at all    
    if params[:search_type].present? || params[:media_type].present? || params[:release_type].present?

      # textual search
      search_type = params[:search_type] ? params[:search_type].map {|type| type.to_sym} : nil

      # media types
      media_types = params[:media_type].map {|type| type.to_i} if params[:media_type].present?

      # release types
      release_types = params[:release_type].map {|type| type.to_i} if params[:release_type].present?

      # grab the albums, based on the given search criteria
      @compositions = Composition.search_by(search_type, params[:search_value], media_types, release_types)
      
    end

  end

  def show

    # get the requested album
    comp = Composition.find(params[:id])

    # get all editions of the same album, sorting appropriately
    @other_editions = Composition.where(Title: comp.Title).sort do |a, b| 

      # first sort by medium
      medium_order = Composition::MEDIA_TYPES[a.Medium] <=> Composition::MEDIA_TYPES[b.Medium]

      # if the media match, sort the ones *without* notes higher
      if medium_order == 0
        if  (a.Comments.present? and b.Comments.nil?) 
          medium_order = 1
        elsif (a.Comments.nil? and b.Comments.present?) 
          medium_order = -1
        else 
          medium_order = 0
        end
      end

      medium_order

    end

    # separate out the first of the editions, it gets pride of place
    @comp = @other_editions.shift

    # get album art (if any)
    @associated_images = get_associated_images(comp.Title)

  end

  def get_associated_images(title)
    Dir["public/images/album-art/*"].entries.select { |name| name.index(/#{title}/i) }.sort.map{ |name| name.sub("public/", "").sub("[", "%5B").sub("]", "%5D")}
  end

end
