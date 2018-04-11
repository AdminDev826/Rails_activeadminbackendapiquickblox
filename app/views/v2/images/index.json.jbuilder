images = @images

json.images images do |image|
  json.id image.id
  json.link image.link
end
