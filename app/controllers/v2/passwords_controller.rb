module V2
	class PasswordsController < ApplicationController

		skip_before_action :authenticate_user_from_token!, only: [:create, :reset_password]

		def create
			user = User.find_by_email(params[:email])
			if user
			  user.send_password_reset
			  render json: { status: { success: "Email sent with password reset instructions." }}
			else
				render json: { status: { error: ["User couldn't found or invalid email"] }}, status: :unprocessable_entity
			end
		end

		def reset_password
		  @user = User.find_by_reset_password_token(params[:id])
		  unless @user.nil?
			  if @user.reset_password_sent_at < 2.hours.ago
			  	render json: { status: { error: ["Password reset token has expired."] }}, status: :unprocessable_entity
			  else @user.update_attributes(update_params)
			  	render json: { status: { success: "Password has been reset." }}
			  end
		  else
		    render json: { status: { error: ["Invalid token. Please try with a valid token."] }}, status: :unprocessable_entity
		  end
		end

		def update
			@user = current_user
			if @user.update_password_with_password(user_params)
				render json: @user, serializer: V2::SessionSerializer, root: nil
      else
        render json: { status: { error: @user.errors.full_messages }}, status: :unprocessable_entity
      end
		end

		def admin_update
			@user = User.find params[:id]
			authorize @user

			if @user.update_attributes(update_params)
				render json: { status: { success: "Password has been changed." }}
			else
				render json: { status: { error: @user.errors.full_messages }}, status: :unprocessable_entity
			end
		end

		private

		def user_params
			params.require(:user).permit(:current_password, :password, :password_confirmation)
		end

		def update_params
			params.require(:user).permit(:password, :password_confirmation)
		end

	end
end
