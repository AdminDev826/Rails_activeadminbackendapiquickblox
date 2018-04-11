module V2
  class AvatarsController < ApplicationController
    include UploadToCloud

    def upload
      @user = User.find(params[:user_id])
      authorize @user, :update?

      link = user_avatar_upload(current_user.id, params[:avatar])
      if link
        current_user.update(:avatar => link)
        render json: { status: { success: "User avatar successfully uploaded." }, image: link}
      else
        render json: { status: { error: ["User avatar could not be uploaded."] }}
      end
    end

  end
end
