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
	
end
