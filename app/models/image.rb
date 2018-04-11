class Image < ActiveRecord::Base
  belongs_to :task
  validates_associated :task
  
  validates :link, presence: true
end
