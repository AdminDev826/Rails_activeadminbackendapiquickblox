module V2

  class DevicesController < ApplicationController

    def index
      @devices = policy_scope(Device).all
    end

    def create
      authorize Device
      @device = Device.new(device_params)
      if @device.save
        render :action => "show"
      else
        render json: { status: { error: @device.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def update
      @device = Device.find(params[:id])
      authorize @device
      if @device.update_attributes(update_params)
        render :action => "show"
      else
        render json: { status: { error: @device.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    private

    def device_params
      params.require(:device).permit(:device_type, :device_token, :push_type, :gcm_sender_id).merge(user: current_user)
    end

    def update_params
      params.require(:device).permit(:device_type, :device_token, :push_type, :gcm_sender_id)
    end
  end
end
