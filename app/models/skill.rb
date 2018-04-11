class Skill < ActiveRecord::Base

	## Relationships
	belongs_to :user

	## Validations
	validates :name, presence: true, uniqueness: { scope: :user_id }
	validates :description, presence: true, if: Proc.new { |s| s.transportation.empty? }

	serialize :transportation, Array
end
