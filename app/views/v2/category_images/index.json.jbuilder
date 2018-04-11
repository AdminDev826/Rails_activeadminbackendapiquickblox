images = @images

json.images images do |image|
  json.id image.id
  json.link image.link
  json.width image.width
  json.height image.height
end
