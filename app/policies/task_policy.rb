class TaskPolicy
  attr_reader :user, :task

  def initialize(user, task)
    @user = user
    @task = task
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
    user.admin? or user.id == task.user_id
  end

  def destroy?
    user.admin? or user.id == task.user_id
  end

  def task_images
    user.admin?
  end

  def archive?
    user.admin? or user.id == task.user_id
  end

  def complete?
    user.admin? or user.id == task.user_id
  end

  def list_task_dates?
    create?
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
