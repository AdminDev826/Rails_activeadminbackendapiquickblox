class FeedbackCategory < ActiveRecord::Base

	## Relationships
	has_many :feedbacks

	## Scopes
	scope :desc, -> { order('created_at DESC') }

	## Validations
  validates :name, uniqueness: true 

  # Methods
  def init
    self.name = self.name.downcase.gsub(/\s+/, "-")
  end
end
