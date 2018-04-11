class PaymentPolicy < Struct.new(:user, :payment)
  attr_reader :user, :payment

  def initialize(user, payment)
    @user = user
    @payment = payment
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

  def update?
    user.admin? or user.id == payment.user_id
  end

  def destroy?
    user.admin? or user.id == payment.user_id
  end

  def sub_merchant?
    create?
  end

  def get_client_token?
    create?
  end

  def update_sub_merchant?
    sub_merchant?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.desc
      else
        scope.archived(false).desc
      end
    end
  end
end
