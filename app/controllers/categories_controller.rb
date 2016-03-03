class CategoriesController < ApplicationController
  def index
    @sections = Category.find(params[:id]).sections
  end
end
