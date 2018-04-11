class AddAndroidFieldsToDevices < ActiveRecord::Migration
  def change
  	add_column :devices, :push_type, :string
  	add_column :devices, :gcm_sender_id, :string
  end
end

