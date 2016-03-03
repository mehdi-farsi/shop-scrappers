class WebsitesController < ApplicationController
  def index
    @website = Website.find(params[:id])
  end
end
