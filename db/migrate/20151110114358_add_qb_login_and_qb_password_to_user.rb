class AddQbLoginAndQbPasswordToUser < ActiveRecord::Migration
  def change
  	add_column :users, :qb_login, :string
  	add_column :users, :qb_password, :string
  	add_column :users, :qb_user_token, :string
  	add_column :users, :qb_id, :string
  end
end
