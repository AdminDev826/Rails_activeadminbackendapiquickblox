@dialog_uri=URI("http://api.quickblox.com/chat/Dialog")

{:type => 2, :name => "Chat with Mummy", :occupants_ids => "6584099 6620048"}

"type=2&name=ChatwithBob&occupants_ids=[6584099,6620048]&user[owner_id]=38618"

curl -X POST -H "Content-Type: application/json" -H "QB-Token: 190a344be7b582553984d0b33a98665f87bc9317" -d '{"type": 2, "name": "Chat with Bob, Sam, Garry", "occupants_ids": "55,678,22"}' https://api.quickblox.com/chat/Dialog.json

curl -X POST -H "Content-Type: application/json" -H "QuickBlox-REST-API-Version: 0.1.0" -H "QB-Token: 190a344be7b582553984d0b33a98665f87bc9317" -d '{"login": "vijirajtp", "password": "password"}' http://api.quickblox.com/login.json

r = @qb.login(:login => "vijirajtp", :password => "password")

