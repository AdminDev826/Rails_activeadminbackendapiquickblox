class AddGroupChatIdToTasks < ActiveRecord::Migration
  def change
  	add_column :tasks, :group_chat_id, :string
  end
end
