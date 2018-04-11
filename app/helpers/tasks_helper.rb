module TasksHelper
  include ApplicationHelper

  def filter_status_selector
    @tasks_filter_params.present? ? @tasks_filter_params[:status] : nil
  end

  def filter_category_selector
    @tasks_filter_params.present? ? @tasks_filter_params[:category_id].to_i : nil
  end

  def date_range_value_maker
  	(@start_date && @end_date) ? "#{@start_date} - #{@end_date}" : ""
  end

  def task_images
  	images = @task.images.pluck(:link)
  	if !images.present? && CategoryImage.find_by(id: @task.category_id).present?
  		images = [CategoryImage.find_by(id: @task.category_id).link]
  	end
  	images
  end

end