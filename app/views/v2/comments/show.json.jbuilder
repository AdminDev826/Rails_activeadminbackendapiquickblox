# json.extract! @comment, :id, :user_id, :task_id, :comment, :created_at, :updated_at

comment = @comment

json.id comment.id
json.title comment.comment
json.created_at comment.created_at
json.user do
  json.id comment.user.id
  json.rating comment.user.rating
  json.username comment.user.username
  json.full_name comment.user.full_name
  json.email comment.user.email
  json.avatar comment.user.avatar
end
json.task_id comment.task_id
