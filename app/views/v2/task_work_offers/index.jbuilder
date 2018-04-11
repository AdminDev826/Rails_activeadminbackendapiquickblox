offers = @offers

json.offers offers do |offer|
  json.id offer.id
  json.poster_id offer.task.user.id
  json.price offer.price
  json.comment offer.comment
  json.created_at offer.created_at
  json.accepted_at offer.accepted_at
  json.task_date offer.task_date
  json.taskstatus offer.task.status
  json.status offer.status
  json.worker do
    json.id offer.worker.id
    json.rating offer.worker.rating
    json.username offer.worker.username
    json.full_name offer.worker.full_name
    json.email offer.worker.email
    json.avatar offer.worker.avatar
    json.qb_id offer.worker.qb_id
    json.qb_login offer.worker.qb_login
  end
end
