json.category_notifcations do |json|
	json.array!(@user.user_category_notifications) do |notification|
  	json.category notification.category.name
  	json.enabled notification.enabled
  end
end