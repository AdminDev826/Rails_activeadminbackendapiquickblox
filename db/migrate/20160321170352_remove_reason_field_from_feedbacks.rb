class RemoveReasonFieldFromFeedbacks < ActiveRecord::Migration
  def change
  	remove_column :feedbacks, :reason
  end
end
