class AddBraintreeFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bt_customer_id, :string
    add_column :users, :bt_billing_address_id, :string
    add_column :users, :bt_merchant_id, :string
    add_column :users, :bt_merchant_status, :string
    add_column :users, :bt_merchant_response, :text
  end
end
