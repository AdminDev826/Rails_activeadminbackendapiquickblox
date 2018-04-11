class Feedback < ActiveRecord::Base

  ## Relationships
  belongs_to :user
  belongs_to :feedback_category

  ## Scopes
  scope :desc, -> { order('created_at DESC') }
end
