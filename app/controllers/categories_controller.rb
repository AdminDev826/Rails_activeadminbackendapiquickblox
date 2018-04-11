class CategoriesController < ApplicationController

  before_filter :get_categories, only: [:show,:edit]

  def protect_against_forgery?
    true
  end

  def index
    @categories = Category.all
  end

  def show
    
  end
 
  def edit

  end

  def create
  end

  def new
  end

  def destroy
  end

  def update
  end

private

  def get_categories
    @category = Category.find(params[:id])
  end

end