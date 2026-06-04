Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get 'sign-in', to: 'session#sign_in', as: :sign_in
  post 'sign-in', to: 'session#login', as: :login
  get 'reset-password', to: 'session#reset_password', as: :reset_password
  get 'sign-up', to: 'session#sign_up', as: :sign_up
  # get 'sign-out', to: 'session#sign_out', as: :sign_out
  delete 'sign-out', to: 'session#sign_out', as: :sign_out_delete
  get 'sign-out', to: 'session#sign_out', as: :sign_out
  get 'api/v1/session', to: 'session#get_session', as: :get_session

  ### oauth2 routes
  get '/auth/google_oauth2/callback', to: 'session#create'
  get '/auth/google_oauth2', to: 'session#google_oauth'  # Inicia la autenticación

  namespace :admin do
    get 'master-data', to: 'admin#master_data'
    # period
    get 'period', to: 'period#index'
    get 'period/new', to: 'period#new'
    post 'period', to: 'period#create'
    put 'period/:id', to: 'period#update'
    get 'period/:id/edit', to: 'period#edit'
    get 'period/:id/delete', to: 'period#delete'
    # program-type
    get 'program-type', to: 'program_type#index'
    get 'program-type/new', to: 'program_type#new'
    post 'program-type', to: 'program_type#create'
    put 'program-type/:id', to: 'program_type#update'
    get 'program-type/:id/edit', to: 'program_type#edit'
    get 'program-type/:id/delete', to: 'program_type#delete'
    # industry
    get 'industry', to: 'industry#index'
    get 'industry/new', to: 'industry#new'
    post 'industry', to: 'industry#create'
    put 'industry/:id', to: 'industry#update'
    get 'industry/:id/edit', to: 'industry#edit'
    get 'industry/:id/delete', to: 'industry#delete'
    # specialism
    get 'specialism', to: 'specialism#index'
    get 'specialism/new', to: 'specialism#new'
    post 'specialism', to: 'specialism#create'
    put 'specialism/:id', to: 'specialism#update'
    get 'specialism/:id/edit', to: 'specialism#edit'
    get 'specialism/:id/delete', to: 'specialism#delete'
    # task_type
    get 'task-type', to: 'task_type#index'
    get 'task-type/new', to: 'task_type#new'
    post 'task-type', to: 'task_type#create'
    put 'task-type/:id', to: 'task_type#update'
    get 'task-type/:id/edit', to: 'task_type#edit'
    get 'task-type/:id/delete', to: 'task_type#delete'
    # user
    get 'user', to: 'user#index'
    get 'user/new', to: 'user#new'
    post 'user', to: 'user#create'
    put 'user/:id', to: 'user#update'
    get 'user/:id/edit', to: 'user#edit'
    get 'user/:id/delete', to: 'user#delete'
  end

  namespace :api do
    post 'file/public', to: 'file#upload_user_image'
  end

  namespace :teachers do
    get '/', to: 'home#index'
    get '/abet', to: 'abet#index'
    get '/abet/folders-evidences/new', to: 'abet#folders_evidences'
    post '/abet/folders-evidences', to: 'abet#folders_evidences_generate'
    get '/abet/tasks/:id', to: 'abet#show_task'
    get '/abet/tasks/:id/evidences', to: 'abet#download_evidences'
  end

  match '*unmatched', to: 'errors#not_found', via: :all
  # Defines the root path route ("/")
  root "home#index"
end
