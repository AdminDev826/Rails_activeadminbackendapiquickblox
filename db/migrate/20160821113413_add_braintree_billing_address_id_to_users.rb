class AddBraintreeBillingAddressIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :braintree_billing_address_id, :string
  end
end
