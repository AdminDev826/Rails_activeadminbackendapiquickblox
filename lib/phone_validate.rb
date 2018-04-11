module PhoneValidate

	require "net/http"
	require "net/https"
	require "uri"
	require "json"

	## https://www.neutrinoapi.com/api/phone-validate/

	###### Request Params ############
	## number -> required           ##
	## country-code -> optional     ##
	## ip -> optional               ##
	##################################

	###### Response Params ###########
	## valid -> boolean             ##
	## type -> string               ##
	## is-mobile -> boolean         ##
	## location -> string           ##
	## country-code -> string       ##
	## international-calling-code   ##
  ## international-number         ##
  ## local-number                 ##
  ##################################
  
	def verify(phone_number)
		 
		uri = URI.parse("https://neutrinoapi.com/phone-validate")
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Post.new(uri.request_uri)
		request.set_form_data(
		    {
		      "user-id" => Rails.application.secrets.phone_validate_user_id, 
		      "api-key" => Rails.application.secrets.phone_validate_api_key,
		      "number" => phone_number
		    })
		response = http.request(request)
		result = JSON.parse response.body
	end

end