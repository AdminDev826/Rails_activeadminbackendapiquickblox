module V2

  class TasksController < ApplicationController
    include UploadToCloud

    skip_before_action :authenticate_user_from_token!, only: [:check_new_tasks]
    before_action :find_task, only: [:update, :destroy, :archive, :create_group_chat, :complete, :get_image, :get_category]

    # GET /v1/tasks
    # Get all the tasks
    def index
      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i

      @user = current_user

      if params[:per_page] == 'all'
        @tasks = policy_scope(Task).all
      else
        @tasks = policy_scope(Task).all.page(params[:page]).per(per_page)
      end
      @tasks =  @tasks.status(params[:status]).page(params[:page]).per(per_page) if params[:status].present?
      @tasks = @tasks.category(params[:category].downcase.gsub(/\s+/, "")).page(params[:page]).per(per_page) if params[:category].present?
      @tasks = Task.where(user_id: params[:user_id]).desc.page(params[:page]).per(per_page) if params[:user_id]
      @tasks = Task.find_by_fuzzy_name(params[:search]).page(params[:page]).per(per_page) if params[:search].present?
      @tasks = Task.by_date(params[:date]).desc.page(params[:page]).per(per_page) if params[:date].present?
    end

    def show
      @task = policy_scope(Task).find(params[:id])
      @user = current_user

      offers_list = []
      @offers_arr = @task.work_offers

      @offers_by_worker = @offers_arr.group_by { |o| o.worker_id }
      
      @offers_by_worker.each do |worker, offers|
        offers_list << offers.last
      end
      @offers = offers_list.sort { |a,b| a.created_at <=> b.created_at }
    end

    # POST /v1/tasks
    # Add a new task
    def create
      # Create a new task with following params except imageLinks. Or else the
      # task will have base64 image as attribute.
      authorize Task
      @user = current_user
      
      @task = Task.new(task_params.except(:images_attributes))
      if @task.save
        
        unless task_params[:images_attributes].blank?
          task_params[:images_attributes].each do |img|
            image_hash = {}
            link = task_image_upload(@task.id, img[1][:link])
            
            image_hash[:link] = link
            image_hash[:width] = img[1][:width]
            image_hash[:height] = img[1][:height]
            @task.images.create(image_hash)
          end
        end

        render :action => "show"
      else
        render json: { status: { error: @task.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def update
      authorize @task

      @user = current_user
      if update_params[:images_attributes]
        update_params[:images_attributes].each do |img|
            image_hash = {}
            link = task_image_upload(@task.id, img[1][:link]) unless img[1][:link].blank?
            
            image_hash[:link] = link unless img[1][:link].blank?
            image_hash[:width] = img[1][:width] unless img[1][:width].blank?
            image_hash[:height] = img[1][:height] unless img[1][:height].blank?

            @task_image = nil          
            @task_image = @task.images.find img[1][:id].to_i rescue nil

            if  @task_image.blank?
              @task.images.create(image_hash)
            else
              unless img[1][:delete].blank?
                @task_image.destroy
              else
                @task_image.update_attributes(image_hash)
              end
            end
          end
      else
        puts "No imageLinks"
      end
      render_errors(@task) unless @task.update(update_params.except(:images_attributes))
      render :action => "show"
    end

    def destroy
      authorize @task
      @task.destroy
      head :no_content
    end

    def statuses
      arr = []
      @statuses = Task.statuses.each {|key, value| arr.push({label: key, value: value})}
    end

    def task_images
      @tasks = policy_scope(Task).all
    end

    def search
      @user = current_user
      if params[:users].blank? && params[:q].blank?
        render json: { status: { error: ["Invalid search parameter."] }}, status: :unprocessable_entity
        return
      end

      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i

      if params[:users].blank? && !params[:q].blank?
        # Common search
        @search = Task.ransack(params[:q])
      else
        # Distance search
        if !params[:users].blank? && (!params[:users][:latitude].blank? && !params[:users][:longitude].blank?)
          order_by = params[:order].blank? ? "distance asc" : params[:order]          
          @search = Task.near([params[:users][:latitude], params[:users][:longitude]], params[:miles]).reorder(order_by)

          @search = @search.ransack(params[:q]) unless params[:q].blank?

          @user.update_attributes(latitude: params[:users][:latitude], longitude: params[:users][:longitude])
        end
      end

      # Sort the search result
      @search.sorts = params[:sort] unless params[:sort].blank? || params[:q].blank?

      unless params[:q].blank?

        unless params[:q][:category_id_cont_any].blank?
          # Category search
          all_category_ids = Category.where(id: params[:q][:category_id_cont_any])
          @category_tasks = @search.result.where(:category_id => all_category_ids)
          category_result = true
        end

        @tasks = category_result ? @category_tasks : @search.result.page(params[:page]).per(per_page)
      else
        @tasks = @search.page(params[:page]).per(per_page)
      end
    end

    def archive
      authorize @task

      @task.update_attributes(archived: true)
      head :no_content
    end

    ## API to check new task is there or not with "aftertime" parameter
    def check_new_tasks
      if params[:after_time].blank?
        render json: { status: { error: ["DateTime can't be blank."] }}, status: :unprocessable_entity
        return
      end

      parsed_time = DateTime.strptime(params[:after_time], '%d/%m/%Y %H:%M:%S')
      @task_count = Task.where("created_at > ?", parsed_time.to_s).count
      response_text = @task_count > 0 ? "Yes" : "No"

      render json: { result: response_text }
    end

    def create_group_chat
      if group_chat_params[:group_chat_id]
        @task.update_attribute(:group_chat_id, group_chat_params[:group_chat_id])
        render :action => "show"
      else
        render json: { status: { error: "Missing group chat ID" }}, status: :unprocessable_entity
      end
    end

    def assigned_tasks
      @user = current_user
      authorize @user

      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i

      @assigned_tasks = @user.assigned
      @tasks = @assigned_tasks.page(params[:page]).per(per_page)

      render :action => "index"
    end

    ## Give list of dates whiich has tasks to show orange color in calender
    def list_task_dates
      @user = current_user
      authorize Task

      dates_array = []
      @tasks = []
      dt = DateTime.new(params[:year].to_i, params[:month].to_i, 1)
      start_date = dt.to_date.beginning_of_month
      end_date = dt.to_date.end_of_month

      @tasks = @user.tasks.by_month_and_year(params[:month], params[:year])

      ## Tasks which current user is posted any bid
      offer_task_ids = @user.task_work_offers.pluck(:task_id).uniq
      posted_offer_tasks = Task.where(id: offer_task_ids, created_at: start_date..end_date).order(created_at: :desc)

      ## Tasks which is assigned to current user
      offer_task_ids = @user.task_work_offers.where.not(task_date: nil).pluck(:task_id).uniq
      assigned_tasks = Task.where(id: offer_task_ids, created_at: start_date..end_date).order(created_at: :desc)

      posted_offer_tasks.map {|p| @tasks << p } unless posted_offer_tasks.first.nil?
      assigned_tasks.map {|a| @tasks << a } unless assigned_tasks.first.nil?

      dates_array = @tasks.group_by { |t| t.created_at.strftime("%Y-%m-%d") }.map(&:first)

      render json: { task_dates: dates_array }
    end

    def complete
      authorize @task
      
      @task.completed!
      @task_work_offers = @task.work_offers.where(status: TaskWorkOffer.statuses[:approved])
      
      @task_work_offers.each do |offer|
        offer.completed!
      end
      
      render json: { status:{ success: "Task has been completed."} }
    end

    def get_image
      unless @task.blank?
        if @task.images.blank?
          @task_image = @task.category.category_images.enabled.first.link rescue nil
        else
          @task_image = @task.images.first.link rescue nil
        end
        
        @task_image.blank? ? (render :plain => "No image found") : (redirect_to @task_image)
      else
        render json: { status: { error: ["Couldn't find task."] }}, status: :unprocessable_entity
      end
    end

    def get_category
      unless @task.blank?

        task_category = @task.category
        @category = task_category ? @task.category.name : "Nil"

        render :plain => @category
      else
        render json: { status: { error: ["Couldn't find task."] }}, status: :unprocessable_entity
      end
    end

    def users_tasks
      @user = current_user
      authorize @user

      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i

      @tasks = []
      start_date = params[:date].to_date.beginning_of_day
      end_date = params[:date].to_date.end_of_day

      if params[:date].present?
        @tasks << @user.tasks.by_date(params[:date]).desc

        ## Tasks which current user is posted any bid
        offer_task_ids = @user.task_work_offers.pluck(:task_id).uniq
        posted_offer_tasks = Task.where(id: offer_task_ids, created_at: start_date..end_date).order(created_at: :desc)

        ## Tasks which is assigned to current user
        offer_task_ids = @user.task_work_offers.where.not(task_date: nil).pluck(:task_id).uniq
        assigned_tasks = Task.where(id: offer_task_ids, created_at: start_date..end_date).order(created_at: :desc)

        @tasks << posted_offer_tasks unless posted_offer_tasks.first.nil?
        @tasks << assigned_tasks unless assigned_tasks.first.nil?
        @tasks = @tasks.flatten!.page(params[:page]).per(per_page)

        render :action => "index"
      else
        render json: { status: { error: ["Date shouldn't be blank."] }}, status: :unprocessable_entity
      end
    end

    def open_tasks
      @user = current_user
      authorize @user

      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i

      @open_tasks = @user.open_for_offers
      @tasks = @open_tasks.page(params[:page]).per(per_page)

      render :action => "index"
    end

    private

    def find_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:name, :price, :date, :description, :category, :category_id, :status, :latitude, :longitude, :taskers_needed, images_attributes: [:link, :width, :height]).merge(user: current_user)
    end

    def update_params
      params.require(:task).permit(:name, :price, :date, :description, :category, :category_id, :status, :latitude, :longitude, :taskers_needed, images_attributes: [:id, :link, :width, :height, :delete])
    end

    def group_chat_params
      params.require(:task).permit(:group_chat_id)
    end

  end
end
