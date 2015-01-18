class CompositionsController < ApplicationController

  def index
    
  end

  def show

    # get the requested album
    @comp = Composition.find(params[:id])

    # get other editions of the same album
    @other_editions = Composition.where(Title: @comp.Title).reject{|a| a.COMPID == @comp.COMPID}

    # get album art (if any)
    @associated_images = get_associated_images(@comp.Title)

  end

  def get_associated_images(title)
    Dir["public/images/album-art/*"].entries.select { |name| name.index(/#{title}/i) }.map{ |name| name.sub("public/", "").sub("[", "%5B").sub("]", "%5D")}
  end

end
