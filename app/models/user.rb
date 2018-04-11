class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :validatable

  include PhoneValidate

  ## Attributes
  attr_accessor :login, :cc_first_name, :cc_last_name, :cc_company, :cc_cardholder_name, :cc_num, :cc_exp_month, :cc_exp_year, :cc_cvv, :payment_type, :billing_address, :individual, :address

  enum role: [:user, :admin]
  enum funding_type: [:email, :mobile_phone, :bank]

  ## Callbacks
  after_create :update_access_token!
  after_initialize :set_default_role, if: :new_record?

  ## Relationships
  has_many :tasks, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :reviews, :dependent => :destroy
  has_many :task_work_offers, foreign_key: 'worker_id'
  has_many :devices, :dependent => :destroy
  has_many :skills, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :portfolio_images, dependent: :destroy
  has_many :conversations, foreign_key: :sender_id
  has_many :user_notifications
  has_many :user_category_notifications, dependent: :destroy

  ## Validations
  validates :cc_num, :cc_exp_month, :cc_exp_year, :cc_cvv, presence: true, if: :paid_with_card?
  validates :cc_first_name, :cc_last_name, :cc_company, :cc_cardholder_name, presence: true, if: Proc.new {|user| !user.cc_num.blank? }
  validates :phone_number, format: { with: /\A^\+(?:[0-9] ?){6,14}[0-9]$\z/, on: :update }, if: Proc.new {|user| !user.phone_number.blank? }
  validate  :verify_phone_number, on: :update, if: Proc.new {|user| user.phone_number_changed? }

  serialize :bt_merchant_response

  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city    = geo.city
      obj.zipcode = geo.postal_code
      obj.country = geo.country_code
      obj.address = geo.address
      obj.state   = geo.state
    end
  end

  ## Methods
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions.to_hash).first
    end
  end

  def set_default_role
    self.role ||= :user
  end

  def full_name
    self.first_name.to_s + ' ' + self.last_name.to_s unless self.first_name.blank? || self.last_name.blank?
  end

  def worked
    offer_task_ids = self.task_work_offers.where(status: TaskWorkOffer.statuses[:completed]).pluck(:task_id)
    tasks = Task.where(id: offer_task_ids, status: Task.statuses[:completed]).order(created_at: :desc)
  end

  def open_for_offers
    open_offers_tasks = []

    tasks = self.tasks.where.not(status: Task.statuses[:completed])

    tasks.each do |task|
      assigned_offers_count = task.work_offers.where(status: TaskWorkOffer.statuses[:approved]).count

      assigned_taskers_count = task.taskers_needed.to_i - assigned_offers_count
      open_offers_tasks << task if assigned_taskers_count.to_i > 0
    end
    open_offers_tasks
  end

  def deactivate_user
    self.transaction do
      self.email = "deactivated-" + email
      self.access_token = "deactivated-" + access_token.to_s
      self.save
    end
  end

  def deactivated?
    email =~ /^deactivated-/
  end

  def active_status
    deactivated? ? "Deactive" : "Active"
  end

  def reactivate_user
    self.transaction do
      recover_email
      recover_access_token
      self.save
    end
  end

  def recover_email
    e = self.email.dup
    e.gsub!(/^deactivated-/,'')
    self.email = e
  end

  def recover_access_token
    token = self.access_token.dup
    token.gsub!(/^deactivated-/,'')
    self.access_token = token
  end

  def posted
    self.tasks
  end

  def assigned
    offer_task_ids = self.task_work_offers.where.not(task_date: nil).pluck(:task_id).uniq
    tasks = Task.where(id: offer_task_ids, status: Task.statuses[:in_progress]).order(created_at: :desc)
  end

  ## My posted tasks that has offers received
  def my_posted_tasks
    tasks = self.tasks.joins("LEFT JOIN task_work_offers ON task_work_offers.task_id = tasks.id").includes(:work_offers).where("task_work_offers.task_id = tasks.id AND task_work_offers.status != ?", TaskWorkOffer.statuses[:cancelled]).group("tasks.id").having('count(task_work_offers.id) > ?', 0).order("max(task_work_offers.created_at) desc")
  end

  def rating
    self.reviews.average("rating")
  end

  def has_payment_method?
    !self.bt_customer_id.blank?
  end

  def has_bank_account?
    !self.account_number.blank? || !self.funding_email.blank? || !self.funding_mobile_phone.blank?
  end

  def paid_with_card?
    payment_type == 'card'
  end

  def add_card_at_braintree(address = {})

    billing_address_hsh = Hash.new
    
    unless address.blank?
      billing_address_hsh = {
                    first_name:     address[:first_name],
                    last_name:      address[:last_name],
                    company:        address[:company],
                    street_address: address[:street_address],
                    locality:       address[:locality],
                    region:         address[:region],
                    postal_code:    address[:postal_code]
                  }
    end

    begin
      add_call = Braintree::Customer.create(
              first_name: self.cc_first_name,
              last_name:  self.cc_last_name,
              company:    self.cc_company,

              credit_card: {
                cardholder_name:  self.cc_cardholder_name,
                number:           self.cc_num,
                expiration_month: self.cc_exp_month,
                expiration_year:  self.cc_exp_year,
                cvv:              self.cc_cvv,
                billing_address:  billing_address_hsh,
                options: {
                  verify_card: true
                }
              })
    rescue
      add_call = nil
    end

    return add_call
  end

  def add_sub_merchant_at_braintree(merchant_params)

    case merchant_params[:funding_type]
      when "email"
        destination = Braintree::MerchantAccount::FundingDestination::Email
      when "mobile_phone"
        destination = Braintree::MerchantAccount::FundingDestination::MobilePhone
      when "bank"
        destination = Braintree::MerchantAccount::FundingDestination::Bank
    end

    merchant_account_params = {
      individual: {
        first_name:       merchant_params[:individual][:first_name],
        last_name:        merchant_params[:individual][:last_name],
        email:            merchant_params[:individual][:email],
        phone:            merchant_params[:individual][:phone],
        date_of_birth:    merchant_params[:individual][:date_of_birth],
        address: {
          street_address: merchant_params[:address][:street_address],
          locality:       merchant_params[:address][:locality],
          region:         merchant_params[:address][:region],
          postal_code:    merchant_params[:address][:postal_code]
        }
      },
      funding: {
        descriptor:       "Snaptask Deposit",
        destination:      destination,
        email:            merchant_params[:funding_email],
        mobile_phone:     merchant_params[:funding_mobile_phone],
        account_number:   merchant_params[:account_number],
        routing_number:   merchant_params[:routing_number]
      },
      tos_accepted: true,
      master_merchant_account_id: Rails.application.secrets.master_merchant_account_id
    }
    result = Braintree::MerchantAccount.create(merchant_account_params)

    if !result.blank? and result.success?
      self.update_attributes!(
        funding_type:         User.funding_types[merchant_params[:funding_type]],
        account_number:       merchant_params[:account_number],
        routing_number:       merchant_params[:routing_number],
        funding_email:        merchant_params[:funding_email],
        funding_mobile_phone: merchant_params[:funding_mobile_phone],
        bt_merchant_status:   "Pending",
        bt_merchant_id:       result.merchant_account.id)
    end

    return result
  end

  def update_sub_merchant_at_braintree(merchant_params)

    case merchant_params[:funding_type]
      when "email"
        destination = Braintree::MerchantAccount::FundingDestination::Email
      when "mobile_phone"
        destination = Braintree::MerchantAccount::FundingDestination::MobilePhone
      when "bank"
        destination = Braintree::MerchantAccount::FundingDestination::Bank
    end

    merchant_account_params = {
      individual: {
        first_name:       merchant_params[:individual][:first_name],
        last_name:        merchant_params[:individual][:last_name],
        email:            merchant_params[:individual][:email],
        phone:            merchant_params[:individual][:phone],
        date_of_birth:    merchant_params[:individual][:date_of_birth],
        address: {
          street_address: merchant_params[:address][:street_address],
          locality:       merchant_params[:address][:locality],
          region:         merchant_params[:address][:region],
          postal_code:    merchant_params[:address][:postal_code]
        }
      },
      funding: {
        descriptor:       "Snaptask Deposit",
        destination:      destination,
        email:            merchant_params[:funding_email],
        mobile_phone:     merchant_params[:funding_mobile_phone],
        account_number:   merchant_params[:account_number],
        routing_number:   merchant_params[:routing_number]
      }
    }
    result = Braintree::MerchantAccount.update(self.bt_merchant_id, merchant_account_params)

    if !result.blank? and result.success?
      self.update_attributes!(
        funding_type:         User.funding_types[merchant_params[:funding_type]],
        account_number:       merchant_params[:account_number],
        routing_number:       merchant_params[:routing_number],
        funding_email:        merchant_params[:funding_email],
        funding_mobile_phone: merchant_params[:funding_mobile_phone])
    end

    return result
  end

  def update_password_with_password(params, *options)
    current_password = params.delete(:current_password)

    result = if valid_password?(current_password)
               update_attributes(params, *options)
             else
               self.assign_attributes(params, *options)
               self.valid?
               self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
               false
             end

    clean_up_passwords
    result
  end

  def verify_phone_number
    return if self.phone_number.blank?

    result = verify(self.phone_number)
    if result
      unless result["valid"]
        self.errors.add(:phone_number, :invalid)
        return false
      end
    end

    return true
  end

  def create_notification(message,device_type,notification_type=nil)
    self.user_notifications.build.tap do |notification|
      notification.message = message
      notification.device_type = device_type
      notification.read_status = false
      notification.type = notification_type
      notification.save
    end
  end

  def send_password_reset
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver_now
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def unread_user_activities_count
    PublicActivity::Activity.where(recipient_id: self.id).where(read_status: nil).count
  end

  private

  def update_access_token!
    self.access_token = generate_access_token
    save
  end

  def self.find_from_omniauth(auth)
    where(provider: auth[:provider], uid: auth[:uid]).first_or_create do |user|
      user.provider = auth[:provider]
      user.uid = auth[:uid]
      user.oauth_token = auth[:token]
      user.oauth_expires_at = Time.at(auth[:expires_at].to_i)
      user.first_name = auth[:first_name]
      user.last_name = auth[:last_name]
      user.email = auth[:email]
      user.password = Devise.friendly_token[0,20]
      user.tag_line = auth[:tag_line]
      user.birthday = auth[:birthday]
      user.description = auth[:description]
      user.save
    end
  end

  def generate_access_token
    loop do
      token = "#{self.id}:#{Devise.friendly_token}"
      break token unless User.where(access_token: token).first
    end
  end

end
