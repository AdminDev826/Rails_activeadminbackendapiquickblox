class TasksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :get_task, only: [:show,:edit,:destroy]
  before_filter :authenticate_admin!

  def protect_against_forgery?
    false
  end

  def index
    if params[:id].present? || params[:status].present? || params[:category_id].present?
      @tasks = Task.filter(params.slice(:id, :status, :category_id)).page params[:page]
      @tasks_filter_params = params.slice(:id, :status, :category_id)
    else
      @tasks = Task.all
    end
    @tasks = Task.filter_by_poster(params[:poster],@tasks) if params[:poster].present?
    if params[:price_range].present?
      @min_price, @max_price = params[:price_range].split(/;/)
      @tasks = Task.filter_by_price_range(@min_price, @max_price,@tasks)
    end
    if params[:date_range].present?
      @start_date,@end_date = params[:date_range].split("-")
      @tasks = Task.filter_by_date_range(@start_date,@end_date,@tasks) 
    end
    @tasks = @tasks.order("#{sort_column_for_tasks} #{sort_direction}").page params[:page]
  end

  def get_users
    email_list = User.all.select(:id, :email).map{|u| {name: u.email, code: u.id}}
    # first_name_list = User.all.select(:id, :first_name).where.not(first_name: nil).where.not(first_name: "").
                      # map{|u| {name: u.first_name,code: u.id}}
    render json: (email_list), root: false
  end

  def show
    if @task
      @task_image = CategoryImage.find_by(id: @task.category_id).present? ? CategoryImage.find_by(id: @task.category_id).link : @task.imageLinks.first
    end
  end
 
  def edit
  end

  def create
  end

  def new
  end

  def destroy
    if @task.destroy
      redirect_to tasks_path
    end
  end

  def update
  end

private

  def get_task
    @task = Task.find_by(id: params[:id])
  end

end