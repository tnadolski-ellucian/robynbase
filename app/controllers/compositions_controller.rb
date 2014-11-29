class CompositionsController < ApplicationController

  def index
    
  end

  def show
    @comp = Composition.find(params[:id])
    @associated_images = get_associated_images(@comp.Title)
  end

  def get_associated_images(title)
    Dir["public/images/album-art/*"].entries.select { |name| name.index(/#{title}/i) }.map{ |name| name.sub("public/", "").sub("[", "%5B").sub("]", "%5D")}
  end

end
