class TaskTransaction < ActiveRecord::Base
  belongs_to :task
  belongs_to :worker, class_name: "User"
  
end
