user = @user

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
json.last_active user.last_active
json.created_at user.created_at
json.verified user.verified
json.posted user.tasks.count
json.completed user.task_work_offers.where(status: TaskWorkOffer.statuses[:completed]).count
json.reviews user.reviews.count