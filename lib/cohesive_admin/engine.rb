require 'cohesive_admin/dependencies'

module CohesiveAdmin
  class Engine < ::Rails::Engine
    isolate_namespace CohesiveAdmin


    config.generators do |g|
      g.stylesheets     false
      g.javascripts     false
      g.helper          false
    end

    initializer 'cohesive_admin.include_concerns' do
      ActionDispatch::Reloader.to_prepare do
        ActiveRecord::Base.send(:include, CohesiveAdmin::Concerns::Resource)
        ActiveRecord::Base.send(:include, CohesiveAdmin::Concerns::Sortable)
        ActiveRecord::Base.send(:include, CohesiveAdmin::Concerns::Duplicatable)
         # add new concerns for loading
      end
    end

    initializer "cohesive_admin.load_app_root" do |app|
       CohesiveAdmin.app_root = app.root
    end

    initializer "cohesive_admin.precompile_images" do |app|
       app.config.assets.precompile += ['cohesive_admin/preloader.gif']
    end

    config.after_initialize do

      # presort our managed models
      CohesiveAdmin::Engine.eager_load!
      Rails.application.eager_load!
      CohesiveAdmin.sort_managed_models!
    end


  end
end
