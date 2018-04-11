module V2
  class CommentsController < ApplicationController
    # skip_before_action :authenticate_user_from_token!, only: [:index, :show]
    before_action :set_comment, only: [:show, :update, :destroy]

    def index
      @comments = Task.find(params[:task_id]).comments.all
      render json: @comments, each_serializer: CommentSerializer
    end

    def show
      render json: @comment
    end

    def create
      authorize Comment

      task = Task.find(params[:task_id])
      @comment = task.comments.new(comment_params)
      @comment.user = current_user

      if @comment.save
        render :action => "show"
      else
        render json: { status: { error: @comment.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def update
      authorize @comment

      if @comment.update(comment_params)
        head :no_content
      else
        render json: { status: { error: @comment.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @comment

      @comment.destroy
      head :no_content
    end

    private

      def set_comment
        @comment = Comment.find(params[:id])
      end

      def comment_params
        params.require(:comment).permit(:comment)
      end
  end
end
