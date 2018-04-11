categories = @feedback_categories

json.categories categories do |category|
	json.id category.id
	json.name category.name
end