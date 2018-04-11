class SkillPolicy
  attr_reader :user, :skill

  def initialize(user, skill)
    @user = user
    @skill = skill
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
    user.admin? || user.id == skill.user_id
  end

  def destroy?
    user.id == skill.user_id
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
