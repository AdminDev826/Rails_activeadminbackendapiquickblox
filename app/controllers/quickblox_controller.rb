class QuickbloxController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_admin!

  def protect_against_forgery?
    false
  end

  def index
  end
end