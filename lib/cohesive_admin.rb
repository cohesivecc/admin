require 'simple_form'
require 'compass-rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'materialize-sass'

require "cohesive_admin/configuration"
require "cohesive_admin/routing"
require "cohesive_admin/dashboard"
require "cohesive_admin/engine"

module CohesiveAdmin
	
	def self.namespace
		Rails.application.routes.named_routes[:cohesive_admin].path.source.sub("\\A/", "").to_sym
	end
	
	@@router = nil
	def self.routing
		@@router ||= CohesiveAdmin::Routing.new
	end
	
	
	def self.as_json(options={})
		# pass CohesiveAdmin config settings down to Javascript
		js_config = {
			managed_models: CohesiveAdmin::Dashboard.all.map(&:model_config).compact,
			aws: nil,
			froala: { key:(config.froala[:key] rescue nil) },
			mount_point: "/#{ namespace }"
		}
	
		js_config
	end
	
end
