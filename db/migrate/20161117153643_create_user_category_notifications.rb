class CreateUserCategoryNotifications < ActiveRecord::Migration
  def change
    create_table :user_category_notifications do |t|
      t.references 	:user, 		index: true, foreign_key: true
      t.references 	:category, 	index: true, foreign_key: true
      t.boolean 	:enabled, 	default:false
      t.timestamps 	null: false
    end
  end
end
