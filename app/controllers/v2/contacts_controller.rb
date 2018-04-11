module V2
	class ContactsController < ApplicationController

		def create
			@contact = Contact.new(contact_params)

			if @contact.save
				render json: { status:{ success: "Thank you for contacting us. We are always working on improving SnapTask and your feedback is greatly appreciated!"} }
			else
				render json: { status: { error: @contact.errors.full_messages }}, status: :unprocessable_entity
			end
		end

		private

		def contact_params
      params.require(:contact).permit(:name, :email, :subject, :body)
    end
	end
end
