class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :user_id, null: false
      t.integer :rater_id, null: false
      t.integer :score, null: false, default: 0

      t.timestamps null: false
    end
  end
end
