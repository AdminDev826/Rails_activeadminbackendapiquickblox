devices = @devices

json.devices devices do |device|
	json.id device.id
	json.device_type device.device_type
	json.device_token device.device_token
end