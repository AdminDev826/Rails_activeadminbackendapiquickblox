class FeedbackPolicy

	 attr_reader :user, :feedback

  def initialize(user, feedback)
    @user = user
    @feedback = feedback
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
