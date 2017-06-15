module CohesiveAdmin
	module Generators
		class UpgradeGenerator < Rails::Generators::Base
			
			desc "Upgrades the cohesive_admin CMS config to the new format."
			def upgrade
				
				# get a map of all the available models using their 'old' underscored keys
				translations = { 'en' => { 'admin' => { 'dashboards' => {}, 'fields' => {} }}}
				models = {}
				
				CohesiveAdmin::Dashboard.managed_models.each do |m|
					key = m.name.underscore.gsub(/\//, '_')
					models[key] = m
					
					translations['en']['admin']['dashboards'][key.to_s] = {
						'one'   => m.name,
						'other' => m.name.pluralize
					}
				end
				
				# Consolidate the old config files into a single cohesive_admin.yml
				old_config = {}
				old_config_files = Dir.glob(Rails.root.join("config", "cohesive_admin", "*.yml"))
				
				if(old_config_files.length > 0)
					old_config_files.each do |f|
						# old_config
						model_name = File.basename(f, ".*")
						cfg   = YAML.load_file(f)
						
						cfg['fields'].keys.each do |field|
							
							translations['en']['admin']['fields'][model_name] ||= {}
							translations['en']['admin']['fields'][model_name][field.to_s] = field.to_s.humanize
							
							if(cfg['fields'][field.to_s].is_a?(Hash) && cfg['fields'][field.to_s]['label'])
								translations['en']['admin']['fields'][model_name] ||= {}
								translations['en']['admin']['fields'][model_name][field.to_s] = cfg['fields'][field.to_s].delete('label')
							end
						end
						
						old_config.update({ model_name => cfg })
					end
					
					File.write(Rails.root.join("config", "cohesive_admin.yml"), old_config.to_yaml)
					File.write(Rails.root.join("config", "locales", "admin.en.yml"), translations.to_yaml)
					
					say("Admin config written to config/cohesive_admin.yml", :green)
					say("Admin model and field translations written to config/locales/admin.en.yml", :green)
					
					say("")
					say("You can safely delete your old config/cohesive_admin/ directory.", :yellow)
					say("Models are assumed to be managed. You may remove cohesive_admin directives from all models. Use cohesive_admin(false) to opt out.", :yellow)
					
					# Delete the old config files.
					# FileUtils.rm_rf(Rails.root.join("config", "cohesive_admin"))
				else
					
					say("No previous version of cohesive_admin configs were found.", :green)

				end
								
			end
			
		end
	end
end
