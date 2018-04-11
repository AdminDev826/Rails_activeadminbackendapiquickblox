class AddIsMyOfferAcceptedToTasks < ActiveRecord::Migration
  def change
  	add_column :tasks, :is_my_offer_accepted, :boolean, default: :false
  end
end
