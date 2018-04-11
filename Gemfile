source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem 'active_model_serializers'
gem 'devise'
gem 'rack-cors', require: 'rack/cors'
gem 'sdoc', group: :doc
gem "bcrypt", :require => "bcrypt"
gem 'jquery-rails'
# gem 'thin'
# gem 'unicorn', '~> 5.0.0'
gem 'pundit', '~> 1.0.1'
gem 'faker'
gem 'fog'
gem 'fog-google'
gem 'fuzzily'
gem 'braintree'
# gem 'google-api-client', require: 'google/api_client'
gem 'kaminari'
# gem 'will_paginate'
gem 'api-pagination'
gem 'omniauth-facebook'
gem 'rest-client'
gem 'quickblox', :git => 'https://github.com/DeodorantMan/QuickBlox-RubyGem.git', branch: 'custom'
gem 'mandrill_mailer'
gem 'parse-ruby-client', git: 'https://github.com/adelevie/parse-ruby-client.git', branch: 'master'
gem 'rails-push-notifications'
gem 'geocoder'
gem 'unirest'
gem 'ransack'
gem 'grocer'
# gem 'entangled'
gem 'paypal-sdk-adaptivepayments'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
# Use SCSS for stylesheets
gem 'sass-rails'
gem 'therubyracer'
gem 'uglifier'
# gem 'responders', '~> 2.0'
gem 'public_activity'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
