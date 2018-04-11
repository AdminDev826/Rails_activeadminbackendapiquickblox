class AddFeedbackCategoryIdToFeedbacks < ActiveRecord::Migration
  def change
  	add_column :feedbacks, :feedback_category_id, :integer
  end
end
