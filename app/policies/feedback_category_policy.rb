class FeedbackCategoryPolicy < ApplicationPolicy
  
  attr_reader :user, :feedback_category

  def initialize(user, feedback_category)
    @user = user
    @feedback_category = feedback_category
  end

  def index?
  	true
  end

  def show?
  	index?
  end

  def create?
    user.admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.desc
    end
  end
end
