module V2
	class MessagesController < ApplicationController

		include Entangled::Controller

		def create
			broadcast do
		    @conversation = Conversation.find(params[:conversation_id])
		    @message = @conversation.messages.build(message_params)
		    @message.user_id = current_user.id
		    @message.save!
		    render json: @message
		  end
	  end

	  private

	  def message_params
	    params.require(:message).permit(:body)
	  end
	end
end
