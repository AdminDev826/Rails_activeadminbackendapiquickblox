module V2
	class CategoriesController < ApplicationController

		before_action :set_category, only: [:show, :update, :destroy]

		def index
			authorize Category
			@categories = policy_scope(Category).all
		end

		def create
			@category = Category.new category_params
			authorize Category

			if @category.save
				render :action => "show"
			else
				render json: { status: { error: @category.errors.full_messages }}, status: :unprocessable_entity
			end
		end

		def update
			authorize @category

			if @category.update(category_params)
				render :action => "show"
			else
				render json: { status: { error: @category.errors.full_messages }}, status: :unprocessable_entity
			end
		end

		def destroy
			@category.destroy
			head :no_content
		end

		private

		def set_category
			@category = Category.find(params[:id])
		end

		def category_params
			params.require(:category).permit(:name)
		end
	end
end
