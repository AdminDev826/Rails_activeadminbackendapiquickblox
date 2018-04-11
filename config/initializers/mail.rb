ActionMailer::Base.delivery_method = :smtp  

ActionMailer::Base.smtp_settings = {            
  :address              => "smtp.zoho.com", 
  :port                 => 465,                 
  :user_name            => Rails.application.secrets.zoho_username,
  :password             => Rails.application.secrets.zoho_api_key,         
  :authentication       => :login,
  :ssl                  => true,
  :tls                  => true,
  :enable_starttls_auto => true    
}