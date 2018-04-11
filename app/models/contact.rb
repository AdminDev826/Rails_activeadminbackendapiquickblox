class Contact < ActiveRecord::Base

	## Validations
	validates :name, :email, :subject, presence: true

	## Callbacks
	after_create :send_contact

	SUBJECT_VALUES = { 0 => "Reporting Bug Problem", 1 => "Suggestion", 2 => "General", 3 => "Other" }

	## Methods
	def send_contact
		ContactMailer.new_message(self).deliver_now
	end
end
