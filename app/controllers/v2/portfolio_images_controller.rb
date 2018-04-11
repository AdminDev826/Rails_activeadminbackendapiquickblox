module V2
  class PortfolioImagesController < ApplicationController
    include UploadToCloud

    before_action :set_image, only: [:show, :destroy]

    def index
      @images = User.find(params[:user_id]).portfolio_images.all
    end

    def show
      @image
    end

    def create
      @user = User.find(params[:user_id])
      authorize @user, :update?

      link = portfolio_image_upload(@user.id, image_params[:base64])

      @image = @user.portfolio_images.new(link: link)

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
        @image = PortfolioImage.find(params[:id])
      end

      def image_params
        params.require(:portfolio_image).permit(:base64)
      end
  end
end

