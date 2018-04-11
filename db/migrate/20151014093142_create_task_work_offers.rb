class CreateTaskWorkOffers < ActiveRecord::Migration
  def change
    create_table :task_work_offers do |t|
      t.integer :task_id
      t.integer :worker_id
      t.integer :price

      t.timestamps null: false
    end

    add_index :task_work_offers, :task_id
  end
end
