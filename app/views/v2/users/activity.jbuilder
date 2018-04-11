activities = @activities

json.activities activities do |activity|
	work_offer = TaskWorkOffer.unscoped.where(id: activity.trackable_id).first rescue nil
	
	if activity.trackable_type == "Review"
		review = Review.where(id: activity.trackable_id).first rescue nil
		task = review.task rescue nil
	elsif activity.trackable_type == "Task"
		task = Task.where(id: activity.trackable_id).first  rescue nil
	else
		task = work_offer.task rescue nil
	end

	if activity.key == "task_work_offer.posted"
		notification_code = "TASK_OFFER_POSTED"
		message = "You have one new offer from ['tasker_name'] for ['$price']"
	elsif activity.key == "task_work_offer.assigned"
		notification_code = "TASK_OFFER_ASSIGN"
		message = "Congratulations! ['tasker_name'] has assigned you to this task for ['$price']"
	elsif activity.key == "task_work_offer.cancelled"
		notification_code = "TASK_OFFER_CANCELLED"
		message = "['tasker_name'] has cancelled their offer for ['$price']"
	elsif activity.key == "review.rating"
		notification_code = "TASK_COMPLETE_RATING"
		message = "You have new rating from ['poster_name']"
	elsif activity.key == "task.created"
		notification_code = "NEW_TASK_POSTED_NEARBY"
		message = "A new task has just been posted in ['Category name'] for ['$Amount']"
	end	
			
	json.id activity.id
  json.message message
  json.tasker_name activity.owner.full_name
  json.offer_price work_offer.price unless work_offer.blank?
  unless task.blank?
		json.task_id task.id
	  json.poster_name task.user.full_name
	  json.description task.description
	  json.price task.price
	  json.images task.images
	  json.category task.category ? task.category.name : nil
	  json.category_images task.category.category_images.enabled do |image|
		  json.id image.id
		  json.link image.link
		  json.width image.width
		  json.height image.height
		end
	end
	json.notification_code notification_code
	json.read_status activity.read_status
	json.created_at activity.created_at
end