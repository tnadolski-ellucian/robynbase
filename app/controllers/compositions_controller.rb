class CompositionsController < ApplicationController

  # types of media, and the order in which they should appear
  $MEDIA_TYPES = {
    'CD'         => 0,
    'Vinyl LP'   => 1,
    'Vinyl 12"'  => 2,
    'Vinyl 7"'   => 3,
    'Cassette'   => 4,
    'CD 3"'      => 5,
    'CD Single'  => 6,
    'DVD'        => 7,
    'Fixel-disc' => 8,
    'Videotape'  => 9,
    'Other'      => 10
  }

  $MEDIA_TYPES.default = 10;

  def index
    
    if params[:search_type].present?
      @compositions = Composition.search_by(params[:search_type] ? params[:search_type].map {|type| type.to_sym} : nil, params[:search_value])
    end

  end

  def show

    # get the requested album
    comp = Composition.find(params[:id])

    # get all editions of the same album, sorting appropriately
    @other_editions = Composition.where(Title: comp.Title).sort do |a, b| 

      # first sort by medium
      medium_order = $MEDIA_TYPES[a.Medium] <=> $MEDIA_TYPES[b.Medium]

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
