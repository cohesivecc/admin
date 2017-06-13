module CohesiveAdmin
  class DashboardController < CohesiveAdmin::BaseController
    def index
       redirect_to new_session_path
     end
	end
end
