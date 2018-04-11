require 'faker'

def new_image
    url = "http://uifaces.com/api/v1/random"
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
    result = JSON.parse(data)
    image = result['image_urls']['epic']
    puts "*** uifaces image fetched"
    return image
end


###
### CREATE USERS
###

User.create!(
  email:'lilcech@gmail.com',
  username:'lilcech',
  password:'letmein123',
  avatar: new_image,
  role: 'admin',
  phone_number: "+12345678901",
  zipcode: Faker::Address.zip,
  city: Faker::Address.city,
  state: Faker::Address.state,
  country: Faker::Address.country_code
)

6.times do |i|
  User.create!(
    email: Faker::Internet.email,
    username: Faker::Internet.user_name,
    password: 'password',
    avatar: new_image,
    phone_number: "+12345678901",
    zipcode: Faker::Address.zip_code,
    city: Faker::Address.city,
    state: Faker::Address.state,
    country: Faker::Address.country_code
  )

  puts "*** created user #{i}"
end


###
### CREATE CATEGORIES
###

categories = ["uncategorized", "cleaning", "moving", "handyman", "pickup-and-delivery", "yard-care", "plumbing", "general-labor", "carpentry"]

categories.each do |c|
  Category.create!(name: c)
  puts "*** created category #{c}"
end

###
### CREATE TASKS
###

40.times do |i|
  user = User.all.sample

  t = Task.new(
    # name: Faker::Name.title,
    description: Faker::Lorem.paragraph,
    user: user,
    category: Category.all.sample,
    status: rand(Task.statuses.count),
    price: Faker::Commerce.price,
    # date: Faker::Date.forward(23),
    created_at: Faker::Date.backward(80),
    latitude: Faker::Address.latitude,
    longitude: Faker::Address.longitude,
  )

  # COMMENTS
  # Faker::Number.between(0, 10).times do
  #   t.comments.new({user:User.all.sample, comment:Faker::Lorem.sentence(2), created_at:Faker::Date.backward(80)})
  # end

  puts "*** task #{i} created"
  t.save!
end


###
### CREATE USER REVIEWS
###

# 100.times do
#   Review.create(
#     user:User.all.sample,
#     reviewer:User.all.sample,
#     task:Task.all.sample,
#     rating:Faker::Number.between(0,5),
#     created_at:Faker::Date.backward(80)
#   )
# end
