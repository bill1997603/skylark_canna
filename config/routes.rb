Rails.application.routes.draw do
  namespace :admin do
    root to: 'problems#index'
    get :login, to: 'sessions#new'
    post :login, to: 'sessions#create'
    delete :logout, to: 'sessions#destroy'
    resources :problems do
      collection do
        get :template
        post :upload
        get :search
      end
    end

    resources :papers, except: [:edit, :update] do
      collection do
        get :dash
        get :search
      end

      member do
        get :duplicate
        patch :terminate

        get :users, to:  'users#index'
        get :export, to: 'users#export'
        post :ranking

        post :repush
      end
    end

    get :tags, to: 'tags#index'

    resources :organizations, only: [:index] do
      member do
        get :children
      end
    end

    scope '/ranking', as: 'ranking' do
      root to: 'ranking#dash'

      scope '/individual', as: 'individual' do
        root to: 'ranking#individual'
        get :export, to: 'ranking#export_individual'
        post :push, to: 'ranking#push_individual'
      end

      scope '/company', as: 'company' do
        root to: 'ranking#company'
        get :export, to: 'ranking#export_company'
        post :push, to: 'ranking#push_company'
      end
    end
  end

  namespace :users do
    root to: 'users#dash'

    resources :papers, only: [:index, :show] do
      collection do
        get '/:code/new', as: 'new', to: 'papers#new'
        get '/:code/organizations', as: 'organizations', to: 'papers#organizations'
        post '/:code', as: 'submit', to: 'papers#create'
        get :search
      end

      member do
        get '/detail', to: 'papers#detail'
        get '/ranking', to: 'papers#ranking'
      end
    end

    resources :organizations, only: [:new, :create]

    scope '/ranking', as: 'ranking' do
      get :individual, to: 'ranking#individual'
      get :company, to: 'ranking#company'
    end
  end

  get '/auth/:provider/callback', to: 'sessions#create'
end
