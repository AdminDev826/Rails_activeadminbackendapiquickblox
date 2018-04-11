# Ruby on Rails Task management System App

## Screenshots
[<img src="screenshots/1.png" width="600" />]()
[<img src="screenshots/2.png" width="600" />]()

##Initial Setup
* create a config/database.yml file
* create a config/secrets.yml file
```
bundle install
rake db:create db:migrate db:seed
rails s
```

##Updating
```
git pull origin --BRANCH--
bundle install
rake db:migrate
rails s
```