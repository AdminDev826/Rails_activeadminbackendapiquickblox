feedback = @feedback

json.id feedback.id
json.target_task_id feedback.target_task_id
json.target_user_id feedback.target_user_id
json.reason feedback.feedback_category ? feedback.feedback_category.name : nil