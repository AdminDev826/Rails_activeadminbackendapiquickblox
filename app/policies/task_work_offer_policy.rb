class TaskWorkOfferPolicy
  attr_reader :user, :task_work_offer

  def initialize(user, task_work_offer)
    @user = user
    @task_work_offer = task_work_offer
  end

  def index?
  	user.admin? or user.user?
  end

  def show?
  	user.admin? or user.user?
  end

  def create?
    user.admin? or user.user?
  end

  def update?
    user.admin? or user.id == task_work_offer.worker_id
  end

  def destroy?
    user.admin? or user.id == task_work_offer.worker_id
  end

  def take_offer?
    user.id == @task_work_offer.task.user.id
  end

  def accept_offer?
    take_offer?
  end

  def unassign_offer?
    take_offer?
  end

  def work_complete?
    user.id == @task_work_offer.task.user.id
  end

  def cancel_offer?
    user.admin? or user.id == task_work_offer.worker_id
  end

  ## TODO Remove this code once paypal integration testing completed
  def temp_work_complete?
    user.id == @task_work_offer.task.user.id
  end

end
