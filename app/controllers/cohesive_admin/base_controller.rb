module CohesiveAdmin
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception
		
		# 404 errors for ResourceNotFound
		# 500 error catching for big problems, etc.
		include CohesiveAdmin::ErrorHandling
		
		before_action :load_dashboard
		
		layout 'cohesive_admin/application'
		
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
		
		
    def set_flash(notice, options={})
      klass = options[:class] || 'light-blue'
      now   = options[:now] || false
      if now
        flash.now[:class]   = klass
        flash.now[:notice]  = notice
      else
        flash[:class]       = klass
        flash[:notice]      = notice
      end
    end
    def flash_success(notice, options={}); set_flash(notice, { class: 'teal',  now: false}.update(options)); end
    def flash_error(notice, options={});   set_flash(notice, { class: 'red',  now: false}.update(options)); end
    def flash_notice(notice, options={});  set_flash(notice, { class: 'light-blue',   now: false}.update(options)); end
		
		def flash_msg(notice, options={})
			statuses = {
				success: 'teal',
				error:   'red',
				notice:  'light-blue'
			}
			status = options.delete(:status).to_sym rescue nil
			status = :notice if(statuses[status].nil?)
			css_class = statuses[status]
			
			set_flash(notice, { now: false, class:css_class }.update(options))
		end
		
		
		class << self
			def cohesive_admin_type
				:dashboard
			end
		end
		
  end
end

