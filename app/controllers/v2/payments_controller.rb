module V2
  class PaymentsController < ApplicationController

    skip_before_action :authenticate_user_from_token!, only: [:webhook_notification]

  	def create
      # A headless pundit policy
      authorize :payment, :create?
      
  		user = current_user
  		user.attributes = user_params

  		unless user.has_payment_method?
  			if user.valid?
	  			result = user.add_card_at_braintree(user_params[:billing_address])

	  			if !result.blank? and result.success?
	  				user.update_attributes(bt_customer_id: result.customer.id, bt_billing_address_id: result.customer.addresses.blank? ? '' : result.customer.addresses[0].id)

	  				render json: { status: "Credit Card verified and added successfully." , bt_customer_id: user.bt_customer_id }
	  			else
	  				render json: { status: { error: result.nil? ? ["An error occured. Please try again."] : result.errors }}, status: :unprocessable_entity
	  			end
	  		else
	  			render json: { status: { error: user.errors.full_messages }}, status: :unprocessable_entity
	  		end
  		else
  			render json: { status: "Credit Card already in file.", bt_customer_id: user.bt_customer_id }
  		end
  	end

    def get_client_token
      authorize :payment, :get_client_token?

      @client_token = Braintree::ClientToken.generate
      render json: { client_token: @client_token }
    end

    def sub_merchant
      authorize :payment, :sub_merchant?

      user = current_user

      if user.bt_merchant_id.blank?
        user.attributes = sub_merchant_params

        unless sub_merchant_params.blank? || sub_merchant_params[:individual].blank? || sub_merchant_params[:address].blank?
          result = user.add_sub_merchant_at_braintree(sub_merchant_params)

          if !result.blank? and result.success?
            render json: { status: { success: "Sub Merchant account details has been sent for approval."} }
          else
            render json: { status: { error: result.nil? ? ["An error occured. Please try again."] : result.errors }}, status: :unprocessable_entity
          end

        else
          render json: { status: { error: "Merchant parameters are missing." }}, status: :unprocessable_entity
        end
      else
        render json: { status: { error: "Merchant has already been added." }}, status: :unprocessable_entity
      end
    end

    def update_sub_merchant
      authorize :payment, :update_sub_merchant?

      user = current_user

      unless user.bt_merchant_id.blank?
        user.attributes = sub_merchant_params

        unless sub_merchant_params.blank? || sub_merchant_params[:individual].blank? || sub_merchant_params[:address].blank?
          result = user.update_sub_merchant_at_braintree(sub_merchant_params)

          if !result.blank? and result.success?
            render json: { status: { success: "Merchant account successfully updated."} }
          else
            render json: { status: { error: result.nil? ? ["An error occured. Please try again."] : result.errors }}, status: :unprocessable_entity
          end

        else
          render json: { status: { error: "Merchant parameters are missing." }}, status: :unprocessable_entity
        end
      else
        render json: { status: { error: "Could not find merchant." }}, status: :unprocessable_entity
      end
    end

    def webhook_notification
      logger.info request.raw_post
      logger.info "***************************"

      notification = Braintree::WebhookNotification.parse(request.params["bt_signature"], request.params["bt_payload"])
      logger.info notification

      sub_merchant = User.where(bt_merchant_id: notification.merchant_account.id) rescue nil

      if sub_merchant
        if notification.kind == Braintree::WebhookNotification::Kind::SubMerchantAccountApproved

          logger.info("IPN message: APPROVED")
          sub_merchant.update_attributes(bt_merchant_status: notification.merchant_account.status)
        elsif notification.kind == Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined

          logger.info("IPN message: DECLINED")
          sub_merchant.update_attributes(bt_merchant_status: notification.merchant_account.status, bt_merchant_response: notification.errors)
        end
      end
    end

  	private

    def user_params
      params.permit(:cc_first_name, :cc_last_name, :cc_company, :cc_cardholder_name, :cc_num, :cc_exp_month, :cc_exp_year, :cc_cvv, :payment_type, billing_address: [:first_name, :last_name, :company, :street_address, :locality, :region, :postal_code])
    end

    def sub_merchant_params
      params.require(:user).permit(:account_number, :routing_number, :funding_type, :funding_email, :funding_mobile_phone, individual: [:first_name, :last_name, :email, :phone, :date_of_birth], address: [:street_address, :locality, :region, :postal_code])
    end
  end
end
