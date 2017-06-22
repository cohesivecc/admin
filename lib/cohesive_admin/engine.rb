module CohesiveAdmin
  class Engine < ::Rails::Engine
    isolate_namespace CohesiveAdmin
		
    config.generators do |g|
      g.stylesheets     false
      g.javascripts     false
      g.helper          false
      g.test_framework :rspec, fixture: :false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets          false
    end
		
		initializer 'cohesive_admin.routing', after: :add_routing_paths do |app|
			CohesiveAdmin::Routing.class_eval do
				include Rails.application.routes.mounted_helpers
			end
		end
		
    initializer "cohesive_admin.precompile_images" do |app|
       app.config.assets.precompile += ['cohesive_admin/preloader.gif']
    end
		
		config.after_initialize do			
			ActiveRecord::Base.send(:include, CohesiveAdmin::Concerns::ManagedModel)
      ActiveRecord::Base.send(:include, CohesiveAdmin::Concerns::Sortable)
      ActiveRecord::Base.send(:include, CohesiveAdmin::Concerns::Duplicatable)
			ActiveRecord::Base.send(:include, CohesiveAdmin::Concerns::Searchable)
			ActiveSupport::Inflector.inflections do |inflect|
				inflect.irregular 'base', 'bases'
			end
			
			CohesiveAdmin::Dashboard.init_models
			
		end
		
  end
end
