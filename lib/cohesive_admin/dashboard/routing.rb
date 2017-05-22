module CohesiveAdmin
	class Dashboard
		module Routing
			extend ActiveSupport::Concern

			def route_key
				ActiveModel::Naming.route_key(@model) if @model
			end
	
			def singular_route_key
				ActiveModel::Naming.singular_route_key(@model) if @model
			end

			def path(poly_path=nil)
		
				unless poly_path
					poly_path = [:admin]
					poly_path << id
				end

				# replace :admin with the namespace used
				namespace = CohesiveAdmin.namespace
				pos = poly_path.index(:admin)
				if(!user_defined? || namespace != :admin)
					if(user_defined?)
						poly_path[pos] = namespace
					else
						poly_path[pos] = nil
					end
				end
		
				# prefix the entire path with the correct RoutesProxy
				proxy = if(user_defined?)
									CohesiveAdmin.routing.main_app
								else
									CohesiveAdmin.routing.cohesive_admin
								end		
		
				poly_path.unshift(proxy)
				poly_path.compact
		
			end
			
		end
	end
end