class PortfolioImage < ActiveRecord::Base

	## Relationships
	belongs_to :user

	## Validations
	validates_associated :user
	  
  validates :link, presence: true
end
