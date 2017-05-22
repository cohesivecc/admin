module CohesiveAdmin
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception
		
		# 404 errors for ResourceNotFound
		# 500 error catching for big problems, etc.
		include CohesiveAdmin::ErrorHandling
		
		layout 'cohesive_admin/application'
		
		before_action :load_dashboard
		
		private
		
		def load_dashboard
			@dashboard = CohesiveAdmin::Dashboard.for(controller:self.class, model:params[:model_class], path:request.path)
		end
		
		def namespace
			CohesiveAdmin.config.namespace
		end
		helper_method :namespace
		
		def controller_key
			@key ||= self.class.name.demodulize.sub("Controller", "").singularize.underscore
		end
		helper_method :controller_key
		
		class << self
			def cohesive_admin_type
				:dashboard
			end
		end
		
  end
end

