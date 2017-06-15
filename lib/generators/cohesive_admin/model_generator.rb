require 'rails/generators/model_helpers'

module CohesiveAdmin
  module Generators
    class ModelGenerator < Rails::Generators::Base
			
			argument :names, type: :array, default:[]
      
      desc "This generator creates the default yml config file for an ActiveRecord model that implements cohesive_admin"
			def generate
				
				models = CohesiveAdmin::Dashboard.managed_models
				models = models.select { |m| 
					names.include?(m.name) ||
					names.include?(m.name.underscore)
				} unless(names.blank?)
				
				models.each do |model|
					generate_model_config(model)
				end

			end
			
		private
			
			def generate_model_config(model)
				
				cfg_file = Rails.root.join("config", "cohesive_admin.yml")
				data = YAML.load_file(cfg_file) rescue {}
				
				model_key  = ActiveModel::Naming.route_key(model)
				
				if(!data[model_key] || yes?("Config for #{ model.name } exists.  Overwrite? [Yes|No] (default:No)", :yellow))
					say("generating config for #{ model.name }.", :green)
					dashboard = CohesiveAdmin::Dashboard.for(model:model)
					cfg = dashboard.send(:default_model_config)
					cfg = dashboard.send(:default_fields_from, cfg)
					
					data[model_key] = cfg.to_hash.deep_stringify_keys!
					
					File.write(cfg_file, data.to_yaml)
				end
				
			end
			
		end
	end
end