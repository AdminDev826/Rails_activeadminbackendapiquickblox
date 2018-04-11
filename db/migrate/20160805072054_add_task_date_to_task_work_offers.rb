class AddTaskDateToTaskWorkOffers < ActiveRecord::Migration
  def change
    add_column :task_work_offers, :task_date, :datetime
  end
end
