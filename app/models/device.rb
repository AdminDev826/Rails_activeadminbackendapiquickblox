class Device < ActiveRecord::Base

  ## Relationships
  belongs_to :user

  # Validations
  validates :device_type, :device_token, presence: true
  validates :device_token, uniqueness: true
  
  enum device_type: [:ios, :android, :windows]

  ## Scopes
  scope :desc, -> { order('created_at DESC') }

  ## Methods
  
  def send_notification(message,task_id=nil,notification_type=nil)
    Rails.logger.info "[Android: #{self.android?}]"
    generate_user_notification(message,notification_type)
    set_ios_notification(message,task_id)     if self.ios?
    set_android_notification(message,task_id) if self.android?
    set_windows_notification(message,task_id) if self.windows?
  end

  def set_ios_notification(message,task_id)
    # certificate = Rails.env.production? ? "#{Rails.root}/config/certs/apn_production.pem" : "#{Rails.root}/config/certs/apn_development.pem"
    certificate = "#{Rails.root}/config/certs/apn_development.pem"
    badge_count = self.user.unread_user_activities_count
    
    pusher = Grocer.pusher(
      certificate: certificate,      
      passphrase:  "aaaaaa",                       
      gateway:     "gateway.push.apple.com", 
      port:        2195,                     
      retries:     3                         
    )
    notification = Grocer::Notification.new(
      device_token:      device_token,
      alert:             message,
      badge:             badge_count,
      sound:             "siren.aiff",
      custom: {
        "task_id": task_id
      }
    )

    Rails.logger.info "[Sending Apple Push] for user #{user.id} with device_token #{device_token} and badge_count #{badge_count}"
    pusher.push(notification)
  end

  def generate_user_notification(message,notification_type=nil)
    self.user.create_notification(message,self.device_type,notification_type)
  end

  def set_android_notification(message,task_id)
    Rails.logger.info "[GCM Push entered]"
    app = RailsPushNotifications::GCMApp.new
    app.gcm_key = Rails.application.secrets.gcm_api_key
    if app.save

      notification = app.notifications.build(
        destinations: [self.device_token],
        data: { text: message, task_id: task_id }
      )
      app.push_notifications if notification.save
      Rails.logger.info "[GCM push sent]"
    end
  end

  def set_windows_notification(message,task_id)
    app = RailsPushNotifications::MPNSApp.new
    app.cert = File.read('path/to/your/certificate.pem')
    if app.save

      notification = app.notifications.build(
        destinations: [self.device_token],
        data: {
          title: 'Snaptask Notification',
          message: message,
          type: :toast
        }
      )
      app.push_notifications if notification.save
    end
  end
end
