CohesiveAdmin::Engine.routes.draw do
	
	CohesiveAdmin::Dashboard.manageable_models.each do |model|
		resources ActiveModel::Naming.route_key(model), { controller: :resource, defaults: { model_class:model.name.underscore } } do
	    member do
	      get :clone
	    end
	    collection do
	      get :sort, defaults: { page: 'all' }
	      put :apply_sort
	    end
		end
	end
	CohesiveAdmin::Dashboard.init
	
end
