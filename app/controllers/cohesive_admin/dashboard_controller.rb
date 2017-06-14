module CohesiveAdmin
  class DashboardController < CohesiveAdmin::BaseController
    def index
      @dashboard = OpenStruct.new(
                              title: 'Welcome'
      )
    end
	end
end
