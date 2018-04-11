class TaskWorkOffer < ActiveRecord::Base

  include PublicActivity::Common
  
  attr_accessor :do_not_check_max_offer

  belongs_to :worker, class_name: "User"
  belongs_to :task

  validates_associated :worker, on: :create
  validates_associated :task, on: :create
  validate :check_task_owner, :check_offer_cancelled, :check_max_offers, on: :create

  enum status: [:pending, :pending_approval, :approved, :unassigned, :completed, :cancelled]

  after_create :notify_poster
  after_destroy :delete_activity

  ## Scopes
  scope :desc, -> { order('created_at DESC') }
  default_scope { where(["status != ?", TaskWorkOffer.statuses[:cancelled]]) }

  # TODO
  # * Validations, Worker cant be Poster

  def price_must_not_greater
    return unless self.errors.blank?
    max_price = TaskWorkOffer.where("task_id = ? AND worker_id = ?", self.task_id, self.worker_id).order('price DESC').first.price rescue 0
    return if max_price == 0
    self.errors.add(:price, "shouldn't more than the previous offer.") if self.price.to_i >= max_price.to_i
  end

  def check_task_owner
    return unless self.errors.blank?
    task = Task.find self.task_id
    self.errors.add(:base, "You cannot make offers on tasks you've posted.") if task.user == self.worker
  end

  def check_offer_cancelled
    return unless self.errors.blank?
    
    task_exist = TaskWorkOffer.where("task_id = ? AND worker_id = ?", self.task_id, self.worker_id).first
    self.errors.add(:base, "You have already made an offer. Please cancel it to make a new offer.") if task_exist
  end

  def check_max_offers
    return unless self.errors.blank?
    return if self.do_not_check_max_offer
    
    offer_count = TaskWorkOffer.unscoped.where("task_id = ? AND worker_id = ?", self.task_id, self.worker_id).count
    self.errors.add(:base, "Maximum of 2 offers are allowed.") if offer_count >= 2
  end

  ## Notify Poster when Tasker has made an offer for a task
  def notify_poster
    devices = self.task.user.devices
    return if devices.blank?
    device = devices.last
    device.send_notification("New offer from #{self.worker.first_name} for $#{self.price}", self.task.id, "offered")
  end

  ## Notify Tasker when a Poster has accepted their offer on task
  def notify_tasker
    devices = self.worker.devices
    return if devices.blank?
    device = devices.last
    device.send_notification("Your offer has been accepted by #{self.task.user.full_name} and he or she will be in contact with you shortly to schedule an appointment.",self.task.id, "accepted")
  end

  ## Notify Tasker when a Poster has approved the task the Tasker has just finished
  def notify_tasker_work_completion
    devices = self.worker.devices
    return if devices.blank?
    device = devices.last
    device.send_notification("Poster #{self.task.user.full_name} has approved the task and finished",self.task.id, "finished")
  end

  def notify_tasker_payment_reception
    devices = self.worker.devices
    return if devices.blank?
    device = devices.last
    device.send_notification("Poster #{self.task.user.full_name} has paid you the amount of $#{self.price} for task #{self.task.description}", "paid")
  end

  def delete_activity
    activity = PublicActivity::Activity.where('trackable_type = ? AND trackable_id = ?',  'TaskWorkOffer', self.id).first
    activity.destroy if activity
  end

  def charge_client(payment_method_nonce)
    user = self.task.user

    begin
      result = Braintree::Transaction.sale(
        customer_id: user.bt_customer_id,
        merchant_account_id: self.worker.bt_merchant_id,
        payment_method_nonce: payment_method_nonce,
        amount: self.price.to_f,
        service_fee_amount: "10.00",
        options: {
          submit_for_settlement: true
        }
      )
      return result
    rescue Exception => e
      raise e.to_s
      return
    end
  end

  def paypal_pay
    self.paypal_client

    price = self.price.to_f
    commission = 0.05

    recipients = [{
                    email: Rails.application.secrets.paypal_primary_receiver,
                    amount: price,
                    primary: true },
                  {
                    email: self.worker.paypal_email_address,
                    amount: price * (1 - commission),
                    primary: false }
                   ]
                   
    data = @pay_request.build_pay(
      actionType: "PAY",
      cancelUrl: "#{@app_url}/v2/tasks",
      currencyCode: "USD",
      feesPayer: "PRIMARYRECEIVER",
      ipnNotificationUrl: "#{@app_url}/v2/payments/ipn_notify",
      receiver_list: {
                      receiver: recipients
                      },
      returnUrl: "#{@app_url}/v2/tasks"
    )

    begin
      @pay_response = @pay_request.pay(data)
      return @pay_request, @pay_response
    rescue Exception => e
      print(e)
      return e
    end
  end

  def paypal_client
    PayPal::SDK.configure(
      :mode      => "sandbox",  # Set "live" for production
      :app_id    => Rails.application.secrets.paypal_app_id,
      :username  => Rails.application.secrets.paypal_username,
      :password  => Rails.application.secrets.paypal_password,
      :signature => Rails.application.secrets.paypal_signature)

    @app_url = Rails.application.secrets.app_url
    @pay_request = PayPal::SDK::AdaptivePayments.new
  end
end
