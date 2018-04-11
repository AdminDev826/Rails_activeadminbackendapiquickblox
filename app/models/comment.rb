class Comment < ActiveRecord::Base
  belongs_to :task
  belongs_to :user

  validates :comment, presence: true
  validates_associated :user
  validates_associated :task

  default_scope {order('created_at DESC')}

  after_create :notify_poster

  ## Notify Poster when a tasker has commented on their task.
  def notify_poster
    devices = self.task.user.devices
    return if devices.blank?
    
    devices.each do |device|
      device.send_notification("Worker #{self.user.username} has commented as '#{self.comment}'")
    end
  end
end
