CohesiveAdmin::Engine.routes.draw do

    root to: "dashboard#index"

    resources :sessions do
      collection do
        get :forgot_password
        post :reset_password
        get :logout
      end
    end

    resources :s3_assets, only: [:index, :delete] do
      collection do
        delete :delete
      end
    end

    get :config, to: 'config#index', format: :json, as: 'config'


    CohesiveAdmin::Engine.eager_load!
    Rails.application.eager_load!

    CohesiveAdmin.config.managed_models.each do |m|
      resources ActiveModel::Naming.route_key(m), controller: :base, defaults: { class_name: m.name } do #, constraints: { class_name: Regexp.new("^#{m.name}$") }#, concerns: :paginatable
        member do
          if m.admin_config && m.admin_duplicatable?
            get :clone
          end
        end
        collection do
          if m.admin_config && m.admin_sortable?
            get :sort, defaults: { page: 'all' }
            put :apply_sort
          end
        end
      end
    end
end
