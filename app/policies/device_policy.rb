class DevicePolicy
  attr_reader :user, :device

  def initialize(user, device)
    @user = user
    @device = device
  end

  def index?
  	false
  end

  def show?
  	false
  end

  def create?
    user.admin? || user.user?
  end

  def update?
    user.admin? || user.id == device.user_id
  end

  def destroy?
    user.id == device.user_id
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user_id: user.id).desc
    end
  end

end
