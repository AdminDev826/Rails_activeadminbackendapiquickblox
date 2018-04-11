class CategoryImage < ActiveRecord::Base

	## Relationships
	belongs_to :category

	## Validations
	validates_associated :category	  
  validates :link, presence: true

  ##Scopes
  scope :enabled, -> (enabled=true) { where enabled: enabled }
end
