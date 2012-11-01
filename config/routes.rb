# -*- encoding : utf-8 -*-

Apposs::Application.routes.draw do

  mount AppossFile::Engine => "/apposs_file"
  mount Resque::Server, :at => '/tasks'

  match '/auth/:provider/callback' => 'home#callback'

  root :to => 'apps#index'

  get "search/autocomplete_user_email"
  
  namespace :backend, :module => 'backend' do
    resources :apps do
      resources :acls
    end
    
    resources :users
    
    resources :settings
  end

  resources :directive_groups

  resources :directive_templates

  resources :directive_templates do
    post :load_other, :on => :collection
    post :add_all, :on => :collection
  end

  resources :machines do
    collection do
      post :change_user
      get :reload
    end
  end
  
  resources :apps do
    member do
      get :intro
      get :machines
      get :operations
    end

    resources :envs
    resources :ops
    resources :permissions


    resources :operation_templates do
      member do
        get  :group_form
        post :group_execute
        post :execute
      end
    end
    resources :softwares

   
    member do
      get :rooms
      get :operations
      get :old_operations
    end
  end
  
  resources :directives do
    put :event, :on => :member
    get :body, :on => :member
  end
  
  resources :envs do
    get :upload_properties, :on => :collection
  end

  resources :machines do
    member do
      put :change_env
      put :reset
      put :pause
      put :interrupt
      put :clean_all
      put :reconnect
      get :directives
      get :old_directives
    end
  end
  
  resources :operation_templates
  
  resources :operations do
    put :event, :on => :member  
    resources :machines, :module => 'operation' do
      get :directives, :on => :member
    end
    get :pluglets, :on => :member
  end
  resources :softwares
  
  resources :directive_groups do
    get :items, :on => :member
  end
  
  match ':controller(/:action(/:id(.:format)))'
end
