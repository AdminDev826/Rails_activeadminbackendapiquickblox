class ChangeDefaultValueInUserCategoryNotifications < ActiveRecord::Migration
  def up
	  change_column :user_category_notifications, :enabled, :boolean, default: true
	end

	def down
	  change_column :user_category_notifications, :enabled, :boolean, default: false
	end
end
