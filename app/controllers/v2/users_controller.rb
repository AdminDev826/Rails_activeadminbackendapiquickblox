module V2
  class UsersController < ApplicationController
    skip_before_action :authenticate_user_from_token!, only: [:create, :filter, :verify_phone]
    before_filter :find_user, only: [:show, :destroy, :update_role, :force_logout, :worked_tasks, 
                  :ban_id_validation, :clear_id_validation, :task_bids, :picture, :task_counts, :activity]

    include PhoneValidate

    def index
			authorize User
    	@users = User.all
    end

    # POST /v1/users
    # Creates an user
    def create
      @user = User.new user_params
      @quickblox_user = QuickbloxUser.new(@user)

      if @quickblox_user.create
        render json: @user, serializer: V2::SessionSerializer, root: nil
      else
        render json: { status: { error: @user.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    # PUT /v2/users
    # Updates an user
    def update
      @user = current_user
      authorize @user

      if @user.update(update_params)
        render :action => "show"
      else
        render json: { status: { error: @user.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def filter
      if params[:username]
        @user = User.find_by_username(params[:username])
      elsif params[:email]
        @user = User.find_by_email(params[:email])
      else
        render json: { status: { error: ["Couldn't find user."] }}, status: :unprocessable_entity
        return
      end
    end

    def update_role
      authorize current_user

      if @user.update_attributes(role: params[:user][:role])
        render json: { status: { success: "User role has been changed successfully." }}
      else
        render json: { status: { error: @user.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def force_logout
      authorize current_user
      sign_out @user
      head :no_content
    end

    def worked_tasks
      authorize current_user

      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i

      if @user
        @tasks = @user.worked.page(params[:page]).per(per_page)
      else
        render json: { status: { error: ["Couldn't find user."] }}, status: :unprocessable_entity
        return
      end
    end

    def update_last_active
    	authorize current_user
      @user = current_user
      @user.update_attributes(last_active: Time.now)
      head :no_content
      return
    end

    def verify_phone
      unless params[:user][:phone_number].blank?
        result = verify(params[:user][:phone_number])
        if result
          render json: result
        else
          render json: { status: { error: ["Unknown error. Please try again or contact support."] }}, status: :unprocessable_entity
          return
        end
      else
        render json: { status: { error: ["Phone number can't be blank."] }}, status: :unprocessable_entity
        return
      end
    end

    def activity
      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i
      @activities = PublicActivity::Activity.order("created_at desc").where(recipient_id: current_user, recipient_type: "User").page(params[:page]).per(per_page)
    end

    def mark_activity_read
      user_activities = PublicActivity::Activity.where(recipient_id: current_user.id)
      user_activities.each do |activity|
        activity.read_status = true
        activity.save
      end
      render :json => {:success => true}
    end

    def unread_activities
      user_activities = PublicActivity::Activity.where(recipient_id: current_user.id).where(read_status: nil)
      @count = user_activities.count
      render :json => {:unread_count => @count}
    end

    def check_nudity
      authorize current_user
      
      if params[:image_url].blank?
        render json: { status: { error: ["Image can't be blank"] }}, status: :unprocessable_entity
      else
        response = Unirest.post "https://api.sightengine.com/1.0/nudity.json", parameters:{
          url: params[:image_url]}, 
          auth:{:api_user=>"#{Rails.application.secrets.sightengine_api_user}", 
                :api_secret=>"#{Rails.application.secrets.sightengine_api_secret}"}

        render json: response.body
      end
    end

    def list_id_validation
      authorize current_user

      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i
      @users = User.where(verified: false).page(params[:page]).per(per_page)
    end

    def ban_id_validation
      authorize current_user

      @user.update(verified: false)
      render :show
    end

    def clear_id_validation
      authorize current_user

      @user.update(verified: true)
      render :show
    end

    def task_bids
      authorize current_user

      if @user == current_user
        per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i
        @offers = TaskWorkOffer.where(worker_id: @user.id).desc.page(params[:page]).per(per_page)
      else
        render json: { status: { error: ["Couldn't find user."] }}, status: :unprocessable_entity
        return
      end
    end

    def picture
      unless @user.blank?
        if @user.avatar.blank?
          redirect_to 'https://storage.googleapis.com/snaptask_images/user_avatars/default_user.jpg'
        else
          redirect_to @user.avatar
        end
      else
        render json: { status: { error: ["Couldn't find user."] }}, status: :unprocessable_entity
      end
    end

    ## Get user id by facebook uid
    def get_user_id
      @user = User.find_by_uid params[:uid] rescue nil

      if @user
        render json: { user_id: @user.id }
      else
        render json: { status: { error: ["Couldn't find a user."] }}, status: :unprocessable_entity
      end
    end

    def destroy
      authorize current_user

      @user.destroy unless @user == current_user
      head :no_content
    end

    ## Count of Open for offers, Assigned, Awaiting Payments, Completed tasks, My Profile Rating
    def task_counts
      authorize @user

      offer_task_ids = @user.task_work_offers.where(status: TaskWorkOffer.statuses[:completed]).pluck(:task_id)
      completed_tasks_count = Task.where(id: offer_task_ids, status: Task.statuses[:completed]).count

      counts = { open_for_offers: @user.open_for_offers.count, assigned: @user.assigned.count, completed: completed_tasks_count, awaiting_payments: 0, profile_rating: 0 }

      render json: { task_counts: counts }
    end

    ## Tasks for which offers received
    def posted_tasks
      @user = current_user
      authorize @user

      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i
      @tasks = @user.my_posted_tasks.page(params[:page]).per(per_page)
    end

    private

    def user_params
      params.require(:user).permit(:email, :username, :password, :password_confirmation, :role, :first_name, :last_name)
    end

    def update_params
      params.require(:user).permit(:email, :username, :phone_number, :zipcode, :city, :state, :country, :notify_message_replies, :notify_comment_replies, :notify_task_status, :notify_task_bids, :notify_task_assigned, :push_notify_allowed, :first_name, :last_name, :tag_line, :description, :birthday, :paypal_email_address)
    end

    def find_user
      @user = User.find(params[:id] || params[:user_id]) rescue nil
    end
  end
end
