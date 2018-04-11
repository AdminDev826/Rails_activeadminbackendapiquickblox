class CommentPolicy
  attr_reader :user, :comment

  def initialize(user, comment)
    @user = user
    @comment = comment
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
    user.id == comment.user_id
  end

  def destroy?
    user.id == comment.user_id
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # @scope.where(:user_id => @user.id).order(:created_at)
      scope
    end
  end

end
