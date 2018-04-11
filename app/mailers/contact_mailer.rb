class ContactMailer < ActionMailer::Base
	default from: "team@snaptaskapp.com"

	def new_message(contact)
		@contact = contact
    mail(:to => "team@snaptaskapp.com", :subject => "Message from #{contact.name}")
	end
end