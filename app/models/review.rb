class Review < ActiveRecord::Base
  
  include PublicActivity::Common

  belongs_to :user
  belongs_to :reviewer, class_name: 'User'
  belongs_to :task

  validates :rating, presence: true
  validates :user, presence: true
  validates_associated :user
  validates_associated :reviewer

  validate :reviewer_cant_review_himself
  validate :tasker_worked_on_task_being_reviewed

  after_destroy :delete_activity

  def self.update_or_create_new(review)
    existing_review = self.where(review.except(:rating, :message)).first

    if existing_review.present?
      existing_review.update_attributes({rating: review[:rating], message: review[:message]})
      existing_review
    else
      self.create(review)
    end
  end

  def reviewer_cant_review_himself
    if self.reviewer == self.user
      errors.add(:review, "Reviewer can't review himself")
    end
  end

  # We need to make sure the tasker worked on the task being reviewed.
  def tasker_worked_on_task_being_reviewed
  	offer = TaskWorkOffer.where(task_id: self.task.id, worker_id: self.user.id, status: TaskWorkOffer.statuses[:completed]).first
    if !offer
      errors.add(:review, "User #{self.user.username} did not work on task #{self.task.id}.")
    end
  end

  def delete_activity
    activity = PublicActivity::Activity.where('trackable_type = ? AND trackable_id = ?',  'Review', self.id).first
    activity.destroy if activity
  end
end
