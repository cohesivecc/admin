module CohesiveAdmin::ErrorHandling
	extend ActiveSupport::Concern
	
	included do
    unless Rails.env.development?
      rescue_from Exception, with: lambda { |exception| render_500 }
      rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_404 }
    end
	end
	
	private
	
  def render_error(status)
    respond_to do |format|
      format.html {
        render "cohesive_admin/errors/#{status}", status: status
      }
      format.all {
        render nothing: true, status: status
      }
    end
  end
  def render_404
    render_error(404)
  end
  def render_500
    render_error(500)
  end
	
end