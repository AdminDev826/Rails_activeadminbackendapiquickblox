class AddCommentToTaskWorkOffers < ActiveRecord::Migration
  def change
  	add_column :task_work_offers, :comment, :text
  end
end
