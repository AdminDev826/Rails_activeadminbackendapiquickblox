class ChangeNameNullValueInTasks < ActiveRecord::Migration
  def change
  	change_column_null(:tasks, :name, true)
  	change_column_null(:tasks, :date, true)
  end
end
