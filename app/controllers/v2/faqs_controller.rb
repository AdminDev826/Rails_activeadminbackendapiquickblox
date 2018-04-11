module V2
	class FaqsController < ApplicationController

		def index
			@faqs = policy_scope(Faq).all
		end

		def create
			authorize Faq
      
  		@faq = Faq.new(faq_params)
      if @faq.save
        render :action => "show"
      else
        render json: { status: { error: @faq.errors.full_messages }}, status: :unprocessable_entity
      end
		end

		def update
			authorize Faq

			@faq = Faq.find(params[:id])

      if @faq.update_attributes(faq_params)
        render :action => "show"
      else
        render json: { status: { error: @faq.errors.full_messages }}, status: :unprocessable_entity
      end
		end

		private

		def faq_params
			params.require(:faq).permit(:question, :answer)
		end
	end
end
