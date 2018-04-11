class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
  include ApplicationHelper
  include AbstractController::Translation
  include ActionView::Layouts
  include ActionController::Helpers
  include ActionController::ImplicitRender
  include PublicActivity::StoreController
  # include ActionController::RespondWith
  # include ActionController::MimeResponds

  helper_method :is_active_controller, :is_active_action, :protect_against_forgery?, :form_authenticity_token,
                :current_admin, :sort_column_for_users, :sort_direction, :sort_column_for_tasks

  include Pundit
  # protect_from_forgery with: :null_session?

  before_action :authenticate_user_from_token!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_guest_user
    current_user
  end

  # Use devise current_user unless user is nil then use a GuestUser
  def current_user
    user = super
    user || GuestUser.new()
  end
  helper_method :current_user
#   hide_action :current_user

  def protect_against_forgery?
  end

  def form_authenticity_token
  end

  def authenticate_admin!
    unless current_admin.present?
      redirect_to root_path
    end
  end

  ##
  # User Authentication
  # Authenticates the user with OAuth2 Resource Owner Password Credentials Grant
  def authenticate_user_from_token!
    auth_token = request.headers['Authorization']

    if auth_token
      authenticate_with_auth_token auth_token
    else
      set_guest_user
      # authentication_error
    end
  end

  private

  def authenticate_with_auth_token auth_token
    unless auth_token.include?(':')
      authentication_error
      return
    end

    user_id = auth_token.split(':').first
    user = User.where(id: user_id).first

    if user && Devise.secure_compare(user.access_token, auth_token)
      # User can access
      sign_in user, store: false
    else
      authentication_error
    end
  end

  def current_admin
    @current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
  end

  ##
  # Authentication Failure
  # Renders a 401 error
  def authentication_error
    # User's token is either invalid or not in the right format
    render json: { status: { error: ["Authentication Failure. User token is either invalid or not in the right format."]}}, status: 401  # Authentication timeout
  end

  def user_not_authorized
    render json: { status: { error: ['User not authorized for this resource.'] }}, status: 401
  end

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end

  def is_active_action(action_name)
    params[:action] == action_name ? "active" : nil
  end

  private

  def sortable_columns_for_users
    ["email", "created_at","first_name", "last_active" "price"]
  end

  def sortable_columns_for_tasks
    ["id", "price","created_at"]
  end

  def sort_column_for_tasks
    sortable_columns_for_tasks.include?(params[:column]) ? params[:column] : "created_at"
  end

  def sort_column_for_users
    sortable_columns_for_users.include?(params[:column]) ? params[:column] : "email"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
