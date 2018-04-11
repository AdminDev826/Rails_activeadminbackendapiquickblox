class Task < ActiveRecord::Base
  include Filterable
  include PublicActivity::Common

  ## Relationships
  belongs_to :user
  belongs_to :category
  has_many :comments, :dependent => :destroy
  has_many :images, :dependent => :destroy
  has_many :work_offers, class_name: 'TaskWorkOffer', dependent: :destroy

  ## Validations
  #validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true
  #validates :date, presence: true
  validates :status, presence: true
  validates_associated :user
  validate  :check_task_status

  ## Scopes
  scope :id, -> (id) {where(id: id)}
  scope :price_range, -> (min, max) {where("price between ? and ?",min,max)}
  scope :date_range, -> (start_date, end_date) {where("created_at between ? and ?",start_date,end_date)}
  scope :poster, -> (user_id) { where user_id: user_id }
  scope :status, -> (status) { where status: status }
  scope :category_id, -> (category_id) { where category_id: category_id }
  scope :archived, -> (archived=true) { where archived: archived }
  scope :desc, -> { order('created_at DESC') }
  scope :by_month_and_year, (lambda do |month, year|
    dt = DateTime.new(year.to_i, month.to_i, 1)
    start_of_month = dt.beginning_of_month
    end_of_month = dt.end_of_month
    where("created_at >= ? and created_at <= ?", start_of_month, end_of_month).order(id: :asc)
  end)
  scope :by_date, -> (date) { where('created_at >= ? AND created_at <= ?', DateTime.parse(date).beginning_of_day, DateTime.parse(date).end_of_day) }

  # fuzzily_searchable :name
  # fuzzily_searchable :description
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city    = geo.city
      obj.zipcode = geo.postal_code
      obj.country = geo.country_code
      obj.address = geo.address
      obj.state   = geo.state
    end
  end

  enum status: [:open, :saved, :in_progress, :completed]

  ## Callbacks
  after_initialize :init
  after_validation :reverse_geocode, if: lambda{ |obj| obj.latitude_changed? || obj.longitude_changed? }
  after_create :log_activity
  after_destroy :delete_activity

  accepts_nested_attributes_for :images

  ## Methods
  def init
    self.status   ||= "saved"
    self.category ||= Category.find_by_name("other")
  end

  def time_ago_in_words(t1, t2)
    s = t1.to_i - t2.to_i

    resolution = if s > 29030400
      [(s/29030400), 'years']
    elsif s > 2419200
      [(s/2419200), 'months']
    elsif s > 604800
      [(s/604800), 'weeks']
    elsif s > 86400
      [(s/86400), 'days']
    elsif s > 3600
      [(s/3600), 'hours']
    elsif s > 60
      [(s/60), 'minutes']
    else
      [s, 'seconds']
    end

    if resolution[0] == 1
      resolution.join(' ')[0...-1]
    else
      resolution.join(' ')
    end
  end

  def check_task_status
    self.errors.add(:status, "is not possible to update for a completed task.") if self.status_was == 'completed'
  end

  def category_image
    category_image = CategoryImage.find_by(id: self.category_id)
    category_image.present? ? category_image.link : nil
  end

  ransacker :category_id do
     Arel.sql("to_char(tasks.category_id, '999')")
  end

  def self.search(poster)
    where('LOWER(email) LIKE :poster OR LOWER(first_name) LIKE :poster', poster: "%#{poster.downcase}%")
  end

  def self.filter_by_poster(poster,tasks)
    user = User.find_by(email: poster)
    tasks.poster(user.id) if user.present?
  end

  def self.filter_by_price_range(min,max,tasks)
     tasks.price_range(min,max)
  end

  def self.filter_by_date_range(start_date,end_date,tasks)
    tasks.date_range(start_date,end_date)
  end

  def log_activity
    notification_enabled_users = User.joins(:user_category_notifications).where(["user_category_notifications.category_id = ? AND user_category_notifications.enabled IS TRUE", self.category.id]).pluck(:id)
    if notification_enabled_users.count > 0
      nearby_users = User.near([self.latitude, self.longitude])
      nearby_users.each do |user|
        if notification_enabled_users.include?(user.id)
          self.create_activity :created, owner: self.user, recipient: user
        end
      end
    end
  end

  def delete_activity
    activity = PublicActivity::Activity.where('trackable_type = ? AND trackable_id = ?',  'Task', self.id).first
    activity.destroy if activity
  end

end
