# json.array!(@comments) do |comment|
#   json.extract! comment, :id, :user_id, :task_id, :comment
#   json.url comment_url(comment, format: :json)
# end

comments = @comments

json.comments comments do |comment|
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
end
