Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Rails.application.secrets.facebook_api_id, Rails.application.secrets.facebook_api_secret,
           :scope => 'user_about_me, email, publish_actions, user_location, publish_stream, read_stream', :display => 'popup'
end