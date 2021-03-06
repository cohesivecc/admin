module CohesiveAdmin
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    layout :set_layout

    # ensure that the user is logged in as the very first filter
    prepend_before_action :load_user

    unless Rails.env.development?
      rescue_from Exception, with: lambda { |exception| render_500 }
      rescue_from ActionController::RoutingError, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_404 }
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

      def set_layout
        logged_in? ? 'cohesive_admin/application' : 'cohesive_admin/login'
      end

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

      def current_user
        @user
      end
      helper_method :current_user

      def load_user
        unless @user = CohesiveAdmin::User.find(session[:user_id]) rescue nil
          reset_session
          respond_to do |format|
            format.html {
              session[:redirect_path] = request.fullpath
              redirect_to(new_session_path) and return
            }
            format.json {
              render nothing: true, status: 401
            }
          end
        end
      end

      def logged_in?
        !session[:user_id].blank? && !current_user.nil?
      end
      helper_method :logged_in?

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
end
