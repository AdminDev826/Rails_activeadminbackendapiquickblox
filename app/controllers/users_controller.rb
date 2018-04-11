class UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_admin!
  before_filter :get_user, only: [:show,:edit,:update,:destroy,:deactivate, :reactivate]

  def protect_against_forgery?
    false
  end

  def index
    if params["name_or_email"].present?
      filter = FilterPresenter.new
      @users = filter.get_users(params["name_or_email"])
      @users = @users.order("#{sort_column_for_users} #{sort_direction}").page params[:page]
      # @users = @stats.all_users(params[:search]).order("created_at desc")
    else
      @users = User.order("#{sort_column_for_users} #{sort_direction}").page params[:page]
    end
  end

  def show
  end
 
  def edit
  end

  def create
  end

  def new
  end

  def destroy
    if @user.destroy
      redirect_to users_path
    else
      render :show
    end
  end

  def deactivate
    @user.deactivate_user
    redirect_to user_path @user
  end

  def reactivate
    @user.reactivate_user
    redirect_to user_path @user
  end

  def update
    if @user.update(user_params)
      # flash[:notice] = 'Marketing Message was successfully updated.'
      redirect_to users_path
    else
      # flash.now[:error] = "Marketing message could not be updated."
      render :show
    end
  end

private

  def get_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email,:first_name,:last_name,:description,:phone_number,:username,:rating,:role)
  end

end