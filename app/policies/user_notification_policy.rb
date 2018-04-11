class UserNotificationPolicy < Struct.new(:user, :notification)
  attr_reader :user, :notification

  def initialize(user, notification)
    @user = user
    @notification = notification
  end

  def index?
  	false
  end

  def show?
  	false
  end

  def create?
    user.admin? or user.user?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
