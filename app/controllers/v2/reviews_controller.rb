module V2
  class ReviewsController < ApplicationController

  	def index
  		@reviews = Review.where(user_id: params[:user_id])
  	end

    def create

      review = {
        user_id: review_params[:tasker_id],
        task_id: params[:task_id],
        reviewer: current_user,
        rating: review_params[:rating],
        message: review_params[:message]
      }

      @review = Review.update_or_create_new(review)
      
      authorize @review

      if @review.save
        recipient = User.find(review_params[:tasker_id].to_i)
        @review.create_activity :rating, owner: current_user, recipient: recipient
        render json: {status:{success:"Thanks for the review"}}
      else
        render json: {status:{error:@review.errors.full_messages}}
      end
    end

    ## API to check new reviews count with "aftertime" parameter
    def check_new_reviews
      if params[:after_time].blank?
        render json: { status: { error: ["DateTime can't be blank."] }}, status: :unprocessable_entity
        return
      end

      parsed_time = DateTime.strptime(params[:after_time], '%d/%m/%Y %H:%M:%S')
      @reviews_count = Review.where("created_at > ? AND user_id = ?", parsed_time.to_s, params[:user_id].to_i).count

      render json: { result: @reviews_count }
    end

    def rating_count
      authorize :review, :rating_count?

      @user = User.find params[:user_id]
      @stars_count = @user.reviews.group(:rating).count
      render json: { result: @stars_count }
    end

    private

    def review_params
      params.require(:review).permit(:rating, :message, :tasker_id)
    end

  end
end
