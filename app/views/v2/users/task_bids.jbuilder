offers = @offers

json.offers offers do |offer|
  task = offer.task
  json.id offer.id
  json.poster do
    json.id task.user.id
    json.rating task.user.rating
    json.username task.user.username
    json.full_name task.user.full_name
    json.email task.user.email
    json.avatar task.user.avatar
    json.qb_id task.user.qb_id
  end
  json.price offer.price
  json.created_at offer.created_at
  json.worker do
    json.id offer.worker.id
    json.rating offer.worker.rating
    json.username offer.worker.username
    json.full_name offer.worker.full_name
    json.email offer.worker.email
    json.avatar offer.worker.avatar
  end
  json.task do
    json.id task.id
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
  end
end
