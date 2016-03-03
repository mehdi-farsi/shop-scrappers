class WebsitesController < ApplicationController
  def index
    @categories = Website.find(params[:id]).categories
  end
end
