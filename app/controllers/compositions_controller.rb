class CompositionsController < ApplicationController

  def index

    search_type_param  = params[:search_type]
    media_type_param   = params[:media_type]
    release_type_param = params[:release_type]

    if search_type_param.nil?
      params[:search_type] = "title"
    end

    # if the user entered any search terms at all    
    if search_type_param.present? || media_type_param.present? || release_type_param.present?

      # textual search
      search_type = search_type_param ? search_type_param.map {|type| type.to_sym} : nil

      # media types
      media_types = media_type_param.map {|type| type.to_i} if media_type_param.present?

      # release types
      release_types = release_type_param.map {|type| type.to_i} if release_type_param.present?

      # grab the albums, based on the given search criteria
      @compositions = Composition.search_by(search_type, params[:album_search_value], media_types, release_types)

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
