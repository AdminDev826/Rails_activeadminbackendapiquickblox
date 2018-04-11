class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
    	t.integer :user_id
    	t.integer :target_user_id
    	t.integer :target_task_id
    	t.text 		:reason
      t.timestamps null: false
    end
  end
end
