module V2
  class ImagesController < ApplicationController
    include UploadToCloud

    before_action :set_image, only: [:show, :update, :destroy]

    def index
      @images = Task.find(params[:task_id]).images.all
    end

    def show
      @image
    end

    def create
      @task = Task.find(params[:task_id])
      authorize @task, :update?

      link = task_image_upload(@task.id, image_params[:base64])

      @image = @task.images.new(link: link)

      if @image.save
        render :action => "show"
      else
        render json: { status: { error: @image.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def destroy
      @image.destroy
      head :no_content
    end

    private

      def set_image
        @image = Image.find(params[:id])
      end

      def image_params
        params.require(:image).permit(:base64)
      end
  end
end
