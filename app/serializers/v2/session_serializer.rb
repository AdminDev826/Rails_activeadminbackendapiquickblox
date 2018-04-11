module V2
  class SessionSerializer < ActiveModel::Serializer

    attributes :email, :username, :token_type, :user_id, :access_token, :last_active, :qb_login, :qb_password, :first_name, :last_name, :rating, :avatar, :full_name, :tag_line, :birthday, :description, :notify_message_replies, :notify_comment_replies, :notify_task_status, :last_active, :created_at, :verified, :notify_task_bids, :notify_task_assigned, :push_notify_allowed, :funding_type, :account_number, :routing_number, :funding_email, :funding_mobile_phone, :bt_merchant_id, :bt_merchant_status

    def user_id
      object.id
    end

    def token_type
      'Bearer'
    end

  end
end
