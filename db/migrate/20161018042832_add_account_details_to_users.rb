class AddAccountDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :funding_type, :integer
    add_column :users, :account_number, :string
    add_column :users, :routing_number, :string
    add_column :users, :funding_email, :string
    add_column :users, :funding_mobile_phone, :string
  end
end
