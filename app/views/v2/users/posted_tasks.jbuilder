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
	  json.qb_id task.user.qb_id
	  json.qb_login task.user.qb_login
	  json.qb_password task.user.qb_password
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
	json.address task.address
	json.city task.city
	json.state task.state
	json.country task.country
	json.zipcode task.zipcode
	json.taskers_needed task.taskers_needed
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
	json.archived task.archived
	json.is_posted_by_me task.user == @user ? true : false
	json.offers task.work_offers do |offer|
    json.id offer.id
	  json.status offer.status
	  json.price offer.price
	  json.comment offer.comment
	  json.accepted_at offer.accepted_at
	  json.task_date offer.task_date
	end
end
