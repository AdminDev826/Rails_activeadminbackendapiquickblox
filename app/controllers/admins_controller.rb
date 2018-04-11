class AdminsController < ApplicationController
	# helper_method :protect_against_forgery?,:form_authenticity_token,:request_forgery_protection_token
	layout 'empty', only: [:new]

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)
    if @admin.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end

  private
    def admin_params
      params.require(:admin).permit(:email,:password,:password_confirmation)
    end
end