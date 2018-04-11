class Category < ActiveRecord::Base

	## Relationships
	has_many :tasks
	has_many :category_images, dependent: :destroy
	has_one :user_category_notification, dependent: :destroy

	## Scopes
	scope :desc, -> { order('created_at DESC') }

	## Callbacks
  after_initialize :init

  # Methods
  def init
    self.name = self.name.downcase.gsub(/\s+/, "-")
  end

end
