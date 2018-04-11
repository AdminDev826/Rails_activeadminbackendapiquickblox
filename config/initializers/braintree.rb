# Braintree::Configuration.environment = Rails.env.production? ? :production : :sandbox
Braintree::Configuration.environment = :sandbox
Braintree::Configuration.logger = Logger.new('log/braintree.log')
Braintree::Configuration.merchant_id = Rails.application.secrets.braintree_merchant_id
Braintree::Configuration.public_key = Rails.application.secrets.braintree_public_key
Braintree::Configuration.private_key = Rails.application.secrets.braintree_private_key
