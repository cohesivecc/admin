module CohesiveAdmin::Authentication
	extend ActiveSupport::Concern
	
	included do
		prepend_before_action :load_user
		prepend_before_action :load_dashboard
			
		layout 'cohesive_admin/application'
			
		helper_method :current_user
		helper_method :logged_in?
	end
	
private
	
	def current_user
		@user
	end
	
	def logged_in?
		!session[:user_id].blank? && !current_user.nil?
	end
	
	def load_user
		unless @user = CohesiveAdmin::User.find(session[:user_id]) rescue nil
      reset_session
      respond_to do |format|
        format.html {
          session[:redirect_path] = request.fullpath
          redirect_to(cohesive_admin.new_session_path) and return
        }
        format.json {
          render nothing: true, status: 401
        }
      end
		end
	end
	
  def require_administrator
    unless current_user.administrator?
      flash_error("You don't have access to that action")
      redirect_to(root_path)
    end
  end
	
  def log_in_user(user, redirect=true)
    session[:user_id] = user.id
    if(redirect)
      redirect_url = session[:redirect_path].blank? ? root_path : session[:redirect_path]
      redirect_to(redirect_url)
    end
    session[:redirect_path] = nil
  end

end