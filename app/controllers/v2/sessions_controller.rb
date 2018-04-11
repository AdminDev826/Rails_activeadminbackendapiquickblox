module V2
  class SessionsController < ApplicationController

    skip_before_action :authenticate_user_from_token!
    
    before_filter :ensure_params_exist, only: :create
    before_filter :ensure_auth_params_exist, only: :facebook_login

    def create
      @user = User.find_for_database_authentication(login: params[:username])
      return invalid_login_attempt unless @user

      if @user.valid_password?(params[:password])
        if @user.verified
          sign_in :user, @user
          render json: @user, serializer: SessionSerializer, root: nil
        else
          render json: { status: { error: ['User is not verified'] }}, status: :unprocessable_entity
          return
        end
      else
        invalid_login_attempt
      end
    end

    def facebook_login
      @user = User.find_from_omniauth(params[:auth])

      if @user.valid?

        if @user.qb_id.blank? || @user.qb_login.blank?
          @quickblox_user = QuickbloxUser.new(@user)
          @quickblox_user.create
        end
        
        sign_in :user, @user
        render json: @user, serializer: SessionSerializer, root: nil
      else
        render json: { status: { error: @user.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    private

    def ensure_params_exist
      return unless params[:username].blank?
      render json: { status: { error: ['missing username parameter'] }}, status: :unprocessable_entity
    end

    def invalid_login_attempt
      warden.custom_failure!
      render json: { status: { error: ['Invalid login attempt']}}, status: :unprocessable_entity
    end

    def ensure_auth_params_exist
      return unless params[:auth].blank?
      render json: { status: { error: ['missing facebook auth parameter'] }}, status: :unprocessable_entity
    end

  end
end
