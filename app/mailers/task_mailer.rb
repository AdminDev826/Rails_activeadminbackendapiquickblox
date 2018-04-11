class TaskMailer < ActionMailer::Base
	default from: "team@snaptaskapp.com"

	def task_work_confirmation(task_work)
		@task_work = task_work
    mail(:to => @task_work.worker.email, :subject => "Task work offer confirmation")
	end

	def work_offer_approved(task_work)
		@task_work = task_work
    mail(:to => @task_work.task.user.email, :subject => "Task work offer approved")
	end

	def poster_transaction(task_work)
		@task_work = task_work
    mail(:to => @task_work.task.user.email, :subject => "Transaction completed")
	end

	def worker_notification(task_work)
		@task_work = task_work
    mail(:to => @task_work.worker.email, :subject => "Transaction completed")
	end
	
end
