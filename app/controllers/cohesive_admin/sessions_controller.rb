require_dependency "cohesive_admin/application_controller"

module CohesiveAdmin
  class SessionsController < BaseController

    skip_before_action :load_user
    before_action :redirect_if_logged_in, except: [:logout]

    def new
      @object = @klass.new
    end

    def create
      @form_param = @klass.model_name.param_key
      if @object = @klass.authenticate(params[@form_param][:email], params[@form_param][:password])
        flash_success("You have been logged in.")
        log_in_user(@object)
      else
        @object = @klass.new(klass_params)
        flash_error("Invalid credentials, please try again!", {now: true})
        render :new
      end
    end

    def logout
      reset_session
      flash_success("You have been logged out.")
      redirect_to(new_session_path)
    end

    def forgot_password
      @object = @klass.new
    end

    def reset_password
      @form_param = @klass.model_name.param_key
      if @object = @klass.where(email: params[@form_param][:email]).first
        @object.reset_password!(new_session_url)
        flash_success("Your password has been reset and sent to your email address!")
        redirect_to(new_session_path)
      else
        @object = @klass.new(klass_params)
        flash_error("Email not found, please try again!", {now: true})
        render action: 'forgot_password'
      end
    end

  private

    def set_klass
      @klass  = User
    end

    def klass_params
      params.require(@klass.model_name.param_key).permit(:email, :password)
    end

    def redirect_if_logged_in
      redirect_to(root_path) unless session[:user_id].blank?
    end

  end
end
