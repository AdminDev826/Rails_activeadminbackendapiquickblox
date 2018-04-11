class AdminSessionsController < ApplicationController
  layout 'empty'

  def new
  end

  def create
    admin = Admin.authenticate(params[:email], params[:password])
    if admin
      session[:admin_id] = admin.id
      redirect_to dashboard_path, :notice => "Logged in!"
    else
      # flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to root_path, :notice => "Logged out!"
  end
end