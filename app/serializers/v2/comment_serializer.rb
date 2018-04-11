module V2
  class CommentSerializer < ActiveModel::Serializer

  	attributes :id, :user_id, :task_id, :username, :avatar, :comment, :created_at, :updated_at

  	def username
  		object.user.username
  	end

  	def avatar
  		object.user.avatar
  	end

  end
end