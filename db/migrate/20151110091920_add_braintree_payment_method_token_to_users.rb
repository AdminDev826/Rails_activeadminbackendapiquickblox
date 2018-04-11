class AddBraintreePaymentMethodTokenToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :braintree_payment_method_token, :string
  end
end
