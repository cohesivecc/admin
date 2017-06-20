module CohesiveAdmin
  class DashboardController < CohesiveAdmin::BaseController
		
		def default_dashboard
			@dashboard_title = t('admin.title')
		end

	end
end