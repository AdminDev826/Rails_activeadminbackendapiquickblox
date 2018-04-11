class AddLastActiveToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_active, :timestamp
  end
end
