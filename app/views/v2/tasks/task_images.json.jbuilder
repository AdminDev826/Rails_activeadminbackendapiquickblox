tasks = @tasks

json.tasks tasks do |task|
	json.id task.id
	json.imageLinks task.imageLinks
	json.images task.images do |image|
	  json.id image.id
	  json.link image.link
	  json.width image.width
	  json.height image.height
	end
end