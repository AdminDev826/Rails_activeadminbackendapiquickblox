if Rails.env == 'production'
  uri = URI.parse(Rails.application.secrets.redis_url)
  $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
	$redis = Redis.new(:host => 'localhost', :port => 6379)
end