class Message < ActiveRecord::Base
	
	include Entangled::Model
  entangle

	## Relationships
  belongs_to :conversation
  belongs_to :user

  ## Validations
  validates :body, :conversation_id, :user_id, presence: true
end
