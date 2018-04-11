module V2
  class UserSerializer < ActiveModel::Serializer

    attributes :username, :email, :first_name, :last_name, :state, :city, :country, :zipcode, :phone_number, :notify_message_replies, :notify_comment_replies, :notify_task_status, :last_active, :full_name, :tag_line, :birthday, :description

  end
end
