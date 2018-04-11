class Faq < ActiveRecord::Base

	## Validations
	validates :question, :answer, presence: true
end
