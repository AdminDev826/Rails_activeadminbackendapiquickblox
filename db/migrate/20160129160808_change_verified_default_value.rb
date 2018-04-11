class ChangeVerifiedDefaultValue < ActiveRecord::Migration
  def change
  	change_column :users, :verified, :boolean, default: true
  end
end
