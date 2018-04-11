module V2
	class ConversationsController < ApplicationController

		include Entangled::Controller

		def create
			broadcast do
		    if Conversation.between(params[:sender_id], params[:recipient_id]).present?
		      @conversation = Conversation.between(params[:sender_id],params[:recipient_id]).first
		    else
		      @conversation = Conversation.create!(conversation_params)
		    end

		    render json: { conversation_id: @conversation.id }
		  end
	  end

	  def show
	  	broadcast do
		    @conversation = Conversation.find(params[:id])
		    @messages = @conversation.messages
		    render json: @messages
		  end
	  end

	  private

	  def conversation_params
	    params.permit(:sender_id, :recipient_id)
	  end

	end
end
