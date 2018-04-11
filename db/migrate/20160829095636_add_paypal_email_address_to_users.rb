class AddPaypalEmailAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :paypal_email_address, :string
  end
end
