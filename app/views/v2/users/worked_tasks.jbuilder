tasks = @tasks

json.tasks tasks do |task|
	json.id task.id
	json.title task.name
	json.poster do
	  json.id task.user.id
	  json.rating task.user.rating
	  json.username task.user.username
	  json.full_name task.user.full_name
	  json.email task.user.email
	  json.avatar task.user.avatar
	end
	json.category task.category ? task.category.name : nil
	json.taskstatus task.status
	json.date task.date
	json.created_at task.created_at
	json.time_ago task.time_ago_in_words(Time.zone.now, task.created_at) + ' ago'
	json.price task.price
	json.description task.description
	json.latitude task.latitude
	json.longitude task.longitude
	json.imageLinks task.imageLinks
	json.offers_count task.work_offers.count
	json.accepted_offers_count task.accepted_offers_count
	json.images task.images do |image|
	  json.id image.id
	  json.link image.link
	  json.width image.width
	  json.height image.height
	end
	json.category_images task.category.category_images.enabled do |image|
    json.id image.id
    json.link image.link
    json.width image.width
    json.height image.height
  end
	json.group_chat_id task.group_chat_id
end
