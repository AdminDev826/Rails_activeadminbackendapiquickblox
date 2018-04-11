class UserMailer < ActionMailer::Base
	default from: "team@snaptaskapp.com"

	def password_reset(user)
		@user = user
		mail(:to => @user.email, :subject => "Password Reset")
	end
end
