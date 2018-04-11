class AddQbDialogIdToTaskWorkOffer < ActiveRecord::Migration
  def change
  	add_column :task_work_offers, :qb_dialog_id, :string
  end
end
