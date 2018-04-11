class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
  	user.admin?
  end

  def show?
  	user.admin? or user.id == record.id
  end

  def create?
    false
  end

  def update?
    user.admin? or user.id == record.id
  end

  def destroy?
    user.admin?
  end

  def admin_update?
    user.admin?
  end

  def update_role?
    user.admin?
  end

  def force_logout?
    user.admin?
  end

  def worked_tasks?
    user.admin? || user.id == record.id
  end

  def update_last_active?
    user.id == record.id
  end

  def check_nudity?
    admin_update?
  end

  def list_id_validation?
    admin_update?
  end

  def ban_id_validation?
    admin_update?
  end

  def clear_id_validation?
    admin_update?
  end

  def task_bids?
    user.id == record.id
  end

  def assigned_tasks?
    user.id == record.id
  end

  def task_counts?
    user.admin? || user.id == record.id
  end

  def users_tasks?
    assigned_tasks?
  end

  def open_tasks?
    assigned_tasks?
  end

  def posted_tasks?
    assigned_tasks?
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
