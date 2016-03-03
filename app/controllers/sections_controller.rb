class SectionsController < ApplicationController
  def index
    @section = Section.find(params[:id])
  end
end
