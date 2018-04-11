module V2
	class FeedbacksController < ApplicationController

		def index
  		@feedbacks = policy_scope(Feedback).all
  	end

		def create
			feedback = Feedback.new(report_params)
			authorize feedback

			if feedback.save
				render json: { status: { success: "Thanks for the feedback" }}
			else
				render json: { status: { error: feedback.errors.full_messages }}, status: :unprocessable_entity
			end
		end

		def show
			@feedback = policy_scope(Feedback).find(params[:id])
		end

		private

		def report_params
			params.require(:feedback).permit(:target_user_id, :target_task_id, :feedback_category_id).merge(user: current_user)
		end
	end
end
