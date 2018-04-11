class UserNotification < ActiveRecord::Base

#associations  
  belongs_to :user

#scopes
  scope :unread, -> { where(read_status: false) }
  scope :alive, -> {where("deleted != true or deleted is null")}

  enum type: [:offered, :accepted, :finished, :paid]

  def self.mark_notification_read(current_user,landmark=nil)
    notifications = current_user.user_notifications
    # notifications = notifications.where("id <= ?",landmark).unread
    if notifications.present?
      notifications.each do |notification|
        notification.read_status = true
        notification.save
      end
    end
  end

  def self.mark_notification_delete(current_user)
    notifications = current_user.user_notifications.alive
    if notifications.present?
      notifications.each do |notification|
        notification.deleted = true
        notification.save
      end
    end

  end

end