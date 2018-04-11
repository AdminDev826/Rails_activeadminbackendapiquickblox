module V2
	class CategoryImagesController < ApplicationController
		include UploadToCloud

    before_action :find_category, only: [:create, :update]
    before_action :set_image, only: [:update, :show, :destroy]

    def index
      @images = Category.find(params[:category_id]).category_images.enabled
    end

    def show
      @image
    end

    def create
      authorize @category, :update?

      link = category_image_upload(@category.id, image_params[:base64])

      @image = @category.category_images.new(width: image_params[:width], height: image_params[:height], enabled: image_params[:enabled])
      @image.link = link

      if @image.save
        render :action => "show"
      else
        render json: { status: { error: @image.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def update
      authorize @category, :update?

      if image_params[:base64]
        link = category_image_upload(@category.id, image_params[:base64])
        @image.link = link
      end
      @image.width = image_params[:width]
      @image.height = image_params[:height]
      @image.enabled = image_params[:enabled]

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

    def find_category
      @category = Category.find(params[:category_id])
    end

    def set_image
      @image = CategoryImage.find(params[:id])
    end

    def image_params
      params.require(:category_image).permit(:base64, :width, :height, :enabled)
    end
	end
end
