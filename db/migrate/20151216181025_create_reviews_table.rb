class CreateReviewsTable < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :user_id
      t.integer :reviewer_id
      t.integer :task_id
      t.integer :rating
      t.text :message

      t.timestamps null: false
    end
  end
end
