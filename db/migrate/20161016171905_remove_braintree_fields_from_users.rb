class RemoveBraintreeFieldsFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :braintree_customer_id
    remove_column :users, :braintree_payment_method_token
    remove_column :users, :braintree_billing_address_id
  end

  def self.down
    add_column :users, :braintree_customer_id, :string
    add_column :users, :braintree_payment_method_token, :string
    add_column :users, :braintree_billing_address_id, :string
  end
end
