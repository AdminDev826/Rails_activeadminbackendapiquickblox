users = @users

json.users users do |user|
	json.id user.id
	json.username user.username
	json.full_name user.full_name
	json.email user.email
	json.rating user.rating
	json.avatar user.avatar
	json.zipcode user.zipcode
	json.city user.city
	json.state user.state
	json.country user.country
	json.phone_number user.phone_number
	json.tag_line user.tag_line
	json.birthday user.birthday
	json.description user.description
	json.notify_message_replies user.notify_message_replies
	json.notify_comment_replies user.notify_comment_replies
	json.notify_task_status user.notify_task_status
	json.last_active user.last_active
	json.created_at user.created_at
	json.verified user.verified
	json.notify_task_bids user.notify_task_bids
	json.notify_task_assigned user.notify_task_assigned
	json.push_notify_allowed user.push_notify_allowed
	json.posted user.tasks.count
	json.completed user.task_work_offers.where(status: TaskWorkOffer.statuses[:completed]).count
	json.reviews user.reviews.count
end