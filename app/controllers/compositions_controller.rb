class CompositionsController < ApplicationController

  def index
    
  end

  def show
    @comp = Composition.find(params[:id])
  end

end
