require 'quickblox'

class QuickbloxDialog

  attr_accessor :task_id, :poster, :worker
  
  def initialize(task_id, poster, worker)
    @poster = poster
    @worker = worker
    @task_id = task_id
    self.create_quickblox_dialog
  end
  
  def create
  	self.create_quickblox_dialog
  end
  
  def create_quickblox_dialog
  	qb = Quickblox.new

  	data = {class_name: "task", snaptask_id: task_id}
  	
  	qb_dialog_params = {name: "test", type: "2", occupants_ids: "#{worker.qb_id}", data: data}

  	puts qb_dialog_params.inspect

  	login_res = qb.login({login: poster.qb_login, password: poster.qb_password})

  	puts login_res.inspect

  	create_res = qb.create_chat_dialog(qb_dialog_params)

		puts create_res.inspect

		token_res = qb.get_token

		puts token_res.inspect
  end
end