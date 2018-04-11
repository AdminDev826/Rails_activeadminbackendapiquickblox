module V2
  class UserNotificationsController < ApplicationController

    def get_all
      user_notifications = current_user.user_notifications.alive
      render :json  => user_notifications.to_json
    end

    def mark_read
      UserNotification.mark_notification_read(current_user,params[:landmark])
      render :json => {:success => true}
    end

    def mark_delete
      UserNotification.mark_notification_delete(current_user)
      render :json => {success: true}
    end

    def create
      authorize UserNotification

      user = current_user

      @user_notification = user.user_category_notifications.where(category_id: notification_params[:category_id]).first

      if @user_notification.blank?
        @user_notification = current_user.user_category_notifications.new(notification_params)
        @user_notification.save
      else
        @user_notification.update_attributes(notification_params)
      end
      render action: :show
    end

    private

    def notification_params
      params.require(:user).permit(:category_id, :enabled)
    end

  end
end