Rails.application.routes.draw do
  get "log_out" => "admin_sessions#destroy", :as => "log_out"
  get "sign_up" => "admins#new", :as => "sign_up"
  root :to => "admin_sessions#new"
  resources :admins
  resources :admin_sessions
  get 'dashboard' => 'dashboards#dashboard_4', as: 'dashboard'

  devise_for :user, only: [], stateless_token: true, skip: :sessions

	post 'v2/users/update_last_active', to: 'v2/users#update_last_active'
  get 'get_tasks_users', to: 'tasks#get_users'

  resources :users do 
    member do
      post :deactivate
      post :reactivate
    end
  end
  resources :tasks
  resources :categories
  resources :quickblox
  namespace :v2, defaults: { format: :json } do
    resource :login, only: [:create], controller: :sessions
    resources :users, only: [:index, :create, :update, :show, :destroy] do
      collection do
        get :filter, :get_user_id, :posted_tasks
        post :verify_phone
        post :check_nudity
        get 'identification_validation/all' => 'users#list_id_validation'
      end
      member do
        post :update_role
        delete :force_logout
        get :worked_tasks, :task_bids, :picture, :task_counts, :activity
      end
      resources :tasks, only: [:index]
      resource :rating, only: [:create], controller: :ratings
      resources :reviews, only: [:index] do
        collection do
          post :check_new_reviews
          get  :rating_count
        end
      end
      resources :skills
      resources :portfolio_images, only: [:index, :create, :show, :destroy]
      post 'avatar' => 'avatars#upload'
      post 'identification_validation/ban' => 'users#ban_id_validation'
      post 'identification_validation/clear' => 'users#clear_id_validation'
    end

    namespace :chats do
    	get :get_token
    end

    resources :passwords do
      member do
        put :admin_update
        put :reset_password
      end
    end
    resources :tasks do
      collection do
        get  :task_images
        get  :statuses
        post :search
        post :check_new_tasks
        get  :assigned_tasks
        post :list_task_dates
        get  :users_tasks
        get  :open_tasks
      end
      member do
        post :archive
        post :create_group_chat
        get  :get_image
        get  :get_category
      end
      resources :offers, only: [:index, :create], controller: :task_work_offers do
        post 'take'   => 'task_work_offers#take_offer'
        post  'accept' => 'task_work_offers#accept_offer'
        post  'unassign' => 'task_work_offers#unassign_offer'
        post 'pay'    => 'task_work_offers#pay_worker'
        post 'complete'   => 'task_work_offers#work_complete'
        post 'temp_complete'   => 'task_work_offers#temp_work_complete'
        post 'cancel'   => 'task_work_offers#cancel_offer'
        collection do
          get :tasker_offers
        end
      end
      resource :review, only: [:create], controller: :reviews
      resources :comments
      resources :images
    end
    resources :payments, only: [:create] do
      collection do
        post :charge_client
        post :ipn_notify
        get  :get_client_token
        post :sub_merchant
        post :update_sub_merchant
        get  :sub_merchant_info
        post :webhook_notification
      end
    end
    resources :devices
    resources :feedbacks, only: [:index, :create, :show]
    resources :categories, only: [:index, :create, :update, :show, :destroy] do
      resources :category_images, only: [:index, :create, :update, :show, :destroy]
    end
    resources :feedback_categories, only: [:index, :create, :update, :show, :destroy]

    # sockets_for :conversations do
    #   sockets_for :messages
    # end

    resources :contacts, only: [:create]

    resources :faqs, only: [:index, :create, :update]
    put 'user_notifications/mark_read', to: 'user_notifications#mark_read'
    put 'user_notifications/mark_delete', to: 'user_notifications#mark_delete'
    get 'user_notifications/get_all', to: 'user_notifications#get_all'
    put 'users/:id/activity', to: 'users#mark_activity_read'
    get 'users/:id/unread_activity_count', to: 'users#unread_activities'

    resources :user_notifications, only: [:index, :create, :show]
  end

  post 'v2/auth/facebook/callback', to: 'v2/sessions#facebook_login'
end
