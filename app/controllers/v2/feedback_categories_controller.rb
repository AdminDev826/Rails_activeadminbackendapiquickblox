module V2
  class FeedbackCategoriesController < ApplicationController

  	before_action :set_category, only: [:show, :update, :destroy]

		def index
			authorize FeedbackCategory
			@feedback_categories = policy_scope(FeedbackCategory).all
		end

		def create
			@feedback_category = FeedbackCategory.new category_params
			authorize FeedbackCategory

			if @feedback_category.save
				render :action => "show"
			else
				render json: { status: { error: @feedback_category.errors.full_messages }}, status: :unprocessable_entity
			end
		end

		def update
			authorize @feedback_category

			if @feedback_category.update(category_params)
				render :action => "show"
			else
				render json: { status: { error: @feedback_category.errors.full_messages }}, status: :unprocessable_entity
			end
		end

		def destroy
			@feedback_category.destroy
			head :no_content
		end

		private

		def set_category
			@feedback_category = FeedbackCategory.find(params[:id])
		end

		def category_params
			params.require(:feedback_category).permit(:name)
		end
  end
end
