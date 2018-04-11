module V2
  class ChatsController < ApplicationController
  	
  	def get_token
  		@token = QuickbloxUser.get_token(current_user)
  	end
  end
end
