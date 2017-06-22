require "cohesive_admin/dashboard/config"
require "cohesive_admin/dashboard/decoration"
require "cohesive_admin/dashboard/routing"

class CohesiveAdmin::Dashboard
	include CohesiveAdmin::Dashboard::Config
	include CohesiveAdmin::Dashboard::Decoration
	include CohesiveAdmin::Dashboard::Routing

	# A Dashboard is defined by a routed controller within the CohesiveAdmin namespace
	# that may or may not be associated with a specific ActiveRecord model.
	# Dashboards without models can be used for landing pages, informational or stats panels.
	attr_reader :controller
	attr_reader :routes
	attr_reader :config
	attr_reader :model

	attr_reader :collection_fields
	attr_reader :form_fields

	def initialize(*args)
		options = args.extract_options!
		@controller = options[:controller]
		@routes     = {}

		@model   		= options[:model] if(options[:model])
		@model			= CohesiveAdmin::Dashboard.managed_models.select {|m| m.name.underscore == @model }.first if(@model && @model.is_a?(String))

		load_config

		# load authentication for this model's controller (if configured and necessary)
		auth_concern = CohesiveAdmin.config.authentication
		unless(auth_concern == false)
			auth_concern = CohesiveAdmin::Authentication if(auth_concern.nil? || !auth_concern.is_a?(ActiveSupport::Concern))
			@controller.send(:include, auth_concern) unless(@controller.ancestors.include?(auth_concern))
		end

	end

	def user_defined?
		!(@controller.name =~ /\ACohesiveAdmin/)
	end

	def standalone?
		@model.nil?
	end

	def manages_a_model?
		!standalone?
	end

	def id
		if(standalone?)
			@controller.name.gsub(/.+::|Controller$/, '').underscore
		else
			ActiveModel::Naming.route_key(@model)
		end
	end

	def add_route(route)
		@routes[route.defaults[:action]] = { name:route.name, source:route.path.source }
	end

	def strong_params
		unless @strong_params
			@strong_params = [:ca_search]
			a = {}

			@form_fields.select { |k,f| !f.disabled? }.each do |k,field|
				if(field.associated?)

					r = field.reflection
					if(field.nested)

						nested_model	= :"#{k}_attributes"

						nested_params = [:id]
						nested_params += CohesiveAdmin::Dashboard.for(model:r.klass).strong_params rescue []
						nested_params << '_destroy' if field.nested[:allow_destroy]

						a[nested_model] = nested_params - [:ca_search]

					elsif(r.macro == :belongs_to)
						@strong_params << r.foreign_key
						@strong_params << r.foreign_type.to_sym if r.polymorphic?
					elsif(r.macro == :has_many || r.macro == :has_and_belongs_to_many)
						@strong_params << { :"#{ r.name.to_s.singularize }_ids" => [] }
					end
				else
					@strong_params << k
					# if the field is an attachment, allow deletion
					@strong_params << "remove_#{k}" if(field.attachment?)
				end
			end

			@strong_params << a unless a.blank?
		end
		@strong_params
	end

	def model_config
		return nil if standalone?
		path_parts	= path([:admin, route_key])
		path_proxy  = path_parts.shift
		board_uri   = path_proxy.polymorphic_path(path_parts, host:'http://example.com')
		[
			model.name,
			{
				class_name: model.name,
				display_name: singular_title,
				route_key: route_key,
				uri: board_uri
			}
		]
	end

private

	@@collection = nil

	class << self
		
		def init_models
			managed_models.each do |model|
				
				cfg = config_for(model)
				search_fields = cfg[:fields].select { |field,data| 
					data.is_a?(Hash) && data[:searchable] == true
				}
				
				# enable the configured model concerns
				model.admin_sortable(cfg[:sort]) if(cfg[:sort] && !model.admin_sortable?)
				model.admin_searchable           unless(search_fields.empty?)
				model.admin_duplicatable         if(cfg[:duplicate] && !model.admin_duplicatable?)

			end
		end

		def init
			@@collection = nil
			dashboards = {}
			(user_defined_routes + engine_routes).each do |route|
				_controller = route.defaults[:controller]
				_model      = route.defaults[:model_class]

				key         = _model || _controller

				dashboards[key] ||= new({ controller:admin_controllers[_controller], model:_model })
				dashboards[key].add_route(route)
			end
			@@collection = dashboards.values
			@@collection.sort! { |a,b| a.config[:order] <=> b.config[:order] }
			@@collection
		end

		def all
			init unless @@collection
			@@collection
		end

		def for(*args)
			options = args.extract_options!

			return nil unless options[:path] || options[:controller] || options[:model]

			all.select { |board|
				route_exists = true
				if(options[:path])
					test_path = options[:path]
					test_path.sub!(/\A\/#{ CohesiveAdmin.namespace.to_s }/i, "") unless(board.user_defined?)
					route_exists = board.routes.select { |key,r| test_path =~ Regexp.new(r[:source]) }.length > 0
				end

				matches_controller = options[:controller].nil? || (board.controller == options[:controller])

				no_model			= board.model.nil? && options[:model].nil?
				matches_model	= false

				unless(board.model.nil?)
					matches_model = if(options[:model].is_a?(String))
														board.model.name.underscore == options[:model]
													elsif(managed_models.include?(options[:model]))
														board.model == options[:model]
													end
				end

				matches_controller &&
				route_exists &&
				(no_model || matches_model)

			}.first

		end

		def managed_models
			all_manageable_models
		end

		def manageable_models
			all_manageable_models - user_managed_models
		end

		private

		def active_record_models
			# Eager load all models unless it already happened
			Rails.application.eager_load! unless Rails.application.config.eager_load
			CohesiveAdmin::Engine.eager_load!

			# Get all subclasses of ActiveRecord::Base
			ActiveRecord::Base.descendants.keep_if { |m|
				m.table_exists? &&  # whose table exists
				m.name == m.to_s && # that has a name (isn't a constant)
				!(m.name =~ /\AActiveRecord/) # and isn't ActiveRecord::Migration
			}
		end

		def all_manageable_models
			active_record_models.select { |m|
				m.respond_to?(:admin_model?) && m.admin_model?
			}
		end

		def user_managed_models
			model_names = user_defined_routes.map { |r| r.defaults[:model_class] }.compact.uniq
			all_manageable_models.select { |m| model_names.include?(m.name.underscore) }
		end

		def user_defined_routes
			Rails.application.routes.routes.select { |route|
				(route.path.source =~ /\A\\A\/#{ CohesiveAdmin.namespace }[\/(]/) && admin_controllers.has_key?(route.defaults[:controller])
			}
		end

		def engine_routes
			CohesiveAdmin::Engine.routes.routes.select { |route|
				admin_controllers.has_key?(route.defaults[:controller])
			}
		end

		def admin_controllers
			controllers = {}
			CohesiveAdmin::BaseController.descendants.keep_if { |c|
				c.name == c.to_s && # that has a name (isn't a constant)
				!hidden_controllers.include?(c) # isn't a hidden controller (s3 assets, sessions, etc)
			}.each { |c|
				controllers[c.name.underscore.sub(/_controller\z/, '')] = c
			}
			controllers
		end

		def hidden_controllers
			[
				CohesiveAdmin::ConfigController,
				CohesiveAdmin::DashboardController,
				CohesiveAdmin::S3AssetsController,
				CohesiveAdmin::SessionsController
			]
		end

	end

end
