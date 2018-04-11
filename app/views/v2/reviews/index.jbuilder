reviews = @reviews

json.reviews reviews do |review|
  json.id review.id
  json.created_at review.created_at
  json.rating	review.rating
  json.message review.message
  json.reviewer do
    json.id review.reviewer.id
    json.username review.reviewer.username
    json.full_name review.reviewer.full_name
    json.email review.reviewer.email
    json.avatar review.reviewer.avatar
  end
  json.task do
  	json.task_id review.task_id
  	json.category review.task.category ? review.task.category.name : nil
  end
end