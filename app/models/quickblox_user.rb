require 'quickblox'

class QuickbloxUser

  attr_accessor :user
  
  def initialize(user)
    @user = user
    # self.create_quickblox_user
  end
  
  def create
    if self.user.save
      puts "user saved"
      self.create_quickblox_user
    end
  end
  
  def create_quickblox_user
  	qb = Quickblox.new
  	qb_user_params = {user: {
  		login: SecureRandom.uuid, 
  		password: SecureRandom.uuid,
  		external_user_id: @user.id,
      full_name: @user.full_name
  	}}

  	puts qb_user_params.inspect

  	res = qb.signup_user(qb_user_params)

  	if res[:response_code] == "201"
  		puts "singup success 201"

  		qb_user = res[:response_body]

  		self.user.qb_id = qb_user["user"]["id"]
  		self.user.qb_login = qb_user_params[:user][:login]
	  	self.user.qb_password = qb_user_params[:user][:password]
	  	self.user.save
  	else
  		puts "Failed to create quickblox user"
  	end
  end

  def self.get_token(user)
  	qb = Quickblox.new

  	qb.login({login: user.qb_login, password: user.qb_password})
  	token_res = qb.get_token

  	return token_res
  end
end