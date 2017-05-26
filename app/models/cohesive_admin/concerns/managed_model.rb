module CohesiveAdmin::Concerns::ManagedModel
	extend ActiveSupport::Concern
	
	included do	
	end
	
	def admin_order_by
		self.class.admin_order_by
	end
	
	class_methods do
		
		def admin_model?
			self.name == self.to_s && !(self.name =~ /\AActiveRecord/)
		end
		
    def admin_order_by
    	:created_at
    end
		
		def admin_form_fields(*args)
			options = args.extract_options!
			options = options.slice(:controller, :path)
			options[:model] = self
			CohesiveAdmin::Dashboard.for(options).form_fields rescue nil
		end
		
		def cohesive_admin(active=true)
			unless active
				class_eval do
					define_singleton_method(:admin_model?) do
						false
					end
				end
			end
		end
		
	end
end