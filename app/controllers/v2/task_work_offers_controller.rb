module V2
  class TaskWorkOffersController < ApplicationController

    def index
      authorize TaskWorkOffer
      
      offers_list = []
      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i

      @offers_arr = Task.find(params[:task_id]).work_offers.page(params[:page]).per(per_page)
      @offers_by_worker = @offers_arr.group_by { |o| o.worker_id }
      
      @offers_by_worker.each do |worker, offers|
        offers_list << offers.last
      end
      @offers = offers_list.sort { |a,b| a.created_at <=> b.created_at }
    end

    def create
      authorize TaskWorkOffer

      @offer = TaskWorkOffer.new(offer_params)

      if @offer.save
        @offer.create_activity :posted, owner: current_user, recipient: @offer.task.user, parameters: { price: @offer.price }
        render json: { status:{ success: "Thanks for the offer" } }
      else
        render json: { status: { error: @offer.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    ## As a Poster, when pressing the approve offer button​​
    def take_offer
      offer = TaskWorkOffer.find(params[:offer_id])

      authorize offer

      if offer
        if offer.pending?

          random_string = SecureRandom.urlsafe_base64(10)
          offer.status = 'pending_approval'
          offer.confirmation_key = random_string
          offer.save
          offer.notify_tasker

          TaskMailer.task_work_confirmation(offer).deliver_now

          render json: { status:{ success: "You just took the offer from worker #{offer.worker.username} for #{offer.price}"}, confirmation_key: offer.confirmation_key }
        else
          render json: { status: { error: ['Work offer has already been approved or completed.'] }}, status: :unprocessable_entity
        end
      else
        render json: { status: { error: offer.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    ## As a Worker when accepting WorkOffer confirmation notification
    def accept_offer
      offer = TaskWorkOffer.find(params[:offer_id])
      authorize offer

      task = offer.task
      poster = task.user
      worker = offer.worker

      #QuickbloxDialog.new(task.id, poster, worker)

      if offer and task
        assigned_offers_count = task.work_offers.where(status: TaskWorkOffer.statuses[:approved]).count
        remaining_taskers_needed = task.taskers_needed.to_i - assigned_offers_count

        if remaining_taskers_needed > 0
          offer.confirmation_key = nil
          offer.status = 'approved'
          offer.accepted_at = Time.now
          offer.task_date = params[:task_date].to_datetime unless params[:task_date].blank?
          offer.save
          offer.create_activity :assigned, owner: current_user, recipient: worker, parameters: { price: offer.price }

          task.status = 'in_progress'
          task.is_my_offer_accepted = true
          task.accepted_offers_count += 1
          task.save

          #TaskMailer.task_work_confirmation(offer).deliver Not Needed

          render json: { status:{ success: "You have sucessfully accepted the work offer."} }
        else
          render json: { status: { error: ["You are not allowed to accept any offers for this task as you have reached limit."] }}, status: :unprocessable_entity
        end
      else
        render json: { status: { error: ["Work offer could not found. Please try again."] }}, status: :unprocessable_entity
      end
    end

    def unassign_offer
      offer = TaskWorkOffer.find(params[:offer_id])
      authorize offer

      task = offer.task
      poster = task.user
      worker = offer.worker

      if offer and task
        offer.status = 'unassigned'
        offer.save

        unassigned_offers_count = task.work_offers.where(status: TaskWorkOffer.statuses[:unassigned]).size
        total_offer_count = task.work_offers.size
        
        task.status = 'open' if unassigned_offers_count == total_offer_count
        task.accepted_offers_count -= 1
        
        if task.save
          render json: { status:{ success: "Offer was unassigned successfully."} }
        else
          render json: { status: { error: task.errors.full_messages }}, status: :unprocessable_entity
        end
      else
        render json: { status: { error: ["Work offer could not found. Please try again."] }}, status: :unprocessable_entity
      end
    end

    ## As a Poster, when pressing the complete offer button​​
    def work_complete
      offer = TaskWorkOffer.find(params[:offer_id])

      authorize offer

      if offer
        task = offer.task
        if offer.approved?

          offer.update_attributes!(status: 'completed')

          offer.notify_tasker_work_completion

          offers_count = TaskWorkOffer.where(task_id: task.id, status: TaskWorkOffer.statuses[:completed]).count
          task.completed! if task.taskers_needed.to_i == offers_count

          render json: { status:{ success: "You have successfully completed the work from worker #{offer.worker.username}"}}
        else
          render json: { status: { error: ['Work offer did not approved yet or already completed.'] }}, status: :unprocessable_entity
        end
      else
        render json: { status: { error: offer.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    def cancel_offer
      offer = TaskWorkOffer.find(params[:offer_id])

      authorize offer
      task = offer.task

      if offer
        offer.status = 'cancelled'
        offer.do_not_check_max_offer = true
        offer.save!

        assigned_offers_count = task.work_offers.where(status: TaskWorkOffer.statuses[:approved]).count
        
        task.status = 'open' if assigned_offers_count == 0
        task.accepted_offers_count -= 1

        if task.save
          offer.create_activity :cancelled, owner: current_user, recipient: task.user, parameters: { price: offer.price }
          render json: { status:{ success: "Offer was cancelled successfully."} }
        else
          render json: { status: { error: task.errors.full_messages }}, status: :unprocessable_entity
        end
      else
        render json: { status: { error: ["Work offer could not found. Please try again."] }}, status: :unprocessable_entity
      end
    end

    def tasker_offers
      per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i
      @offers = Task.find(params[:task_id]).work_offers.where(worker_id: current_user.id).desc.page(params[:page]).per(per_page)
      render :action => "index"
    end

    ## TODO Remove this method once paypal integration testing completed
    def temp_work_complete
      offer = TaskWorkOffer.find(params[:offer_id])

      authorize offer

      if offer
        task = offer.task
        if offer.approved?

          if offer.worker.has_bank_account?

            begin
              ## Charge amount from poster
              result = offer.charge_client(params[:payment_method_nonce])
              
            rescue Exception => e
              render json: { status: { error: ["An error occured while charging from credit card. Please try again. error: #{e.to_s}"] }}, status: :unprocessable_entity
              return
            end

            if result and result.success?

              offer.update_attributes!(status: 'completed', transaction_id: result.transaction.id, payment_status: 'paid')
              offer.notify_tasker_work_completion
              offer.notify_tasker_payment_reception

              offers_count = TaskWorkOffer.where(task_id: task.id, status: TaskWorkOffer.statuses[:completed]).count
              task.completed! if task.taskers_needed.to_i == offers_count

              render json: { status:{ success: "You have successfully completed the work from worker #{offer.worker.username}"}}
            else
              error_messages = result.errors.map { |error| "Error: #{error.code}: #{error.message}" }

              render json: { status: { error: ["Transaction declined - error: #{error_messages}"] }}, status: :unprocessable_entity
            end
          else
            render json: { status: { error: ["Couldn't find bank account details of this worker. Please add it first and try again."] }}, status: :unprocessable_entity
          end
        else
          render json: { status: { error: ['Work offer does not approved yet.'] }}, status: :unprocessable_entity
        end
      else
        render json: { status: { error: offer.errors.full_messages }}, status: :unprocessable_entity
      end
    end

    private

    def offer_params
      params.require(:offer).permit(:price, :comment).merge(worker: current_user, task_id: params[:task_id])
    end

  end
end
