class DashboardsController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  helper_method :sort_column_for_users, :sort_direction

  before_filter :authenticate_admin!

  skip_before_filter :authenticate_user_from_token!
  
  def dashboard_1
  end

  def dashboard_2
  end

  def dashboard_3
    @extra_class = "sidebar-content"
  end

  def dashboard_4
    @users = User.order("#{sort_column_for_users} #{sort_direction}").page params[:page]
    @total_tasks = Task.all.count
    @total_task_work_offers = TaskWorkOffer.all.count
    # render :layout => "layout_2"
  end

  def dashboard_4_1
  end

  def dashboard_5
  end

end
