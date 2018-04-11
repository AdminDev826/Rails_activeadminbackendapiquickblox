class Conversation < ActiveRecord::Base
	
	include Entangled::Model
  entangle

	## Relationships
	belongs_to :sender, foreign_key: :sender_id, class_name: 'User'
  belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'

  has_many :messages, dependent: :destroy

  ## Validations
  validates_uniqueness_of :sender_id, scope: :recipient_id

  ## Scopes
  scope :involving, -> (user) do
    where("conversations.sender_id = ? OR conversations.recipient_id = ?",user.id, user.id)
  end

  scope :between, -> (sender_id, recipient_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id = ?) OR (conversations.sender_id = ? AND conversations.recipient_id = ?)", sender_id, recipient_id, recipient_id, sender_id)
  end
end
