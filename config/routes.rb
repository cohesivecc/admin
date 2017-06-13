CohesiveAdmin::Engine.routes.draw do
	root to: redirect('/admin/sessions/new')

  resources :sessions, only: [:new, :create] do
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

	get :config, to:'config#index', format: :json, as:'config'

	CohesiveAdmin::Dashboard.manageable_models.each do |model|
		resources ActiveModel::Naming.route_key(model), { controller: :resource, defaults: { model_class:model.name.underscore } } do
	    member do
				if(model.admin_duplicatable?)
					get :duplicate
				end
	    end
	    collection do
				if(model.admin_sortable?)
					get :sort, defaults: { page: 'all' }
	      	put :apply_sort
				end
	    end
		end
	end
	CohesiveAdmin::Dashboard.init

end
