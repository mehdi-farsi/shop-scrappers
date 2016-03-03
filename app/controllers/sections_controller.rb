class SectionsController < ApplicationController
  def index
    @subsections = Section.find(params[:id]).subsections
  end
end
