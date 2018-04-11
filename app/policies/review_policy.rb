class ReviewPolicy
  attr_reader :user, :review

  def initialize(user, review)
    @user = user
    @review = review
  end

  def create?
    # user.admin? or user == review.task.user 
    user.id == review.task.user.id
    # false
  end

  def rating_count?
    user.admin? or user.user?
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
