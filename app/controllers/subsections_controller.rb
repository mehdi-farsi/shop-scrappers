class SubsectionsController < ApplicationController
  def index
    @subsection = Subsection.find(params[:id])
  end
end
