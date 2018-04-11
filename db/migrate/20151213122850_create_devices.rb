class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
    	t.integer :user_id
    	t.integer :device_type
    	t.string :device_token
    	t.string :remote_object_id 
      t.timestamps null: false
    end
  end
end
