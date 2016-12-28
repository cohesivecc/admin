require_dependency "cohesive_admin/application_controller"

module CohesiveAdmin
  class BaseController < ApplicationController


    before_action :set_klass
    before_action :set_header
    before_action :load_object, only: [:edit, :update, :destroy, :show, :duplicate]

    # Force the classes to use the primary key as the to_param within our CMS
    # This addresses the scenario where the to_param fields can be manipulated in CMS,
    # creating a condition whereby the finder method can't find the object to update it because it has changed.
    #
    # Best practice: all your cohesive_admin models should have the 'id' column as the primary key -
    # regardless of what is used as to_param on the front-end of your site.
    around_action do |controller, action|

      @klass.class_eval do
        alias :__cohesive_admin_to_param :to_param
        def to_param() send(self.class.primary_key).to_s end
      end

      begin
        action.call
      ensure
        @klass.class_eval do
          alias :to_param :__cohesive_admin_to_param
        end
      end
    end



    def index
      @skope = @klass.admin_sortable? ? @klass.admin_sorted : @klass.all
      @skope = @skope.page(params[:page]) unless params[:page] == 'all'
      @items = @skope.all

      respond_to do |format|
        format.html { render file: 'cohesive_admin/base/index' }
        format.json { render json: @items.to_json(methods: [:to_label]) }
      end
    end

    def new
      @object = @klass.new

      respond_to do |format|
        format.html { render file: 'cohesive_admin/base/form' }
      end
    end

    def create
      @object = @klass.new(klass_params)
      if @object.save
        respond_to do |format|
          format.html {
            flash_success("#{klass_header} successfully created!")
            redirect_to @klass
          }
          format.json { render json: @object.to_json(methods: [:to_label]) }
        end
      else
        flash_error("There was a problem creating the #{klass_header}.")
        respond_to do |format|
          format.html { render file: 'cohesive_admin/base/form' }
          format.json { render json: @object.to_json(methods: [:to_label]) }
        end
      end
    end

    def edit
      respond_to do |format|
        format.html { render file: 'cohesive_admin/base/form' }
      end
    end

    def update
      if @object.update(klass_params)
        respond_to do |format|
          format.html {
            flash_success("#{klass_header} successfully updated!")
            redirect_to @klass
          }
          format.json { render json: @object.to_json(methods: [:to_label]) }
        end
      else
        flash_error("There was a problem updating the #{klass_header}.")
        respond_to do |format|
          format.html { render file: 'cohesive_admin/base/form' }
          format.json { render json: @object.to_json(methods: [:to_label]) }
        end
      end
    end

    def sort
      render_404 and return unless @klass.admin_sortable?
      @items = @klass.admin_sorted.all
      render file: 'cohesive_admin/base/sort'
    end

    def apply_sort
      params[:item].each_with_index do |x, i|
        m = @klass.find(x)
        m.update_attribute(@klass.admin_sort_column, i)
      end
      render text: ''
    end

    def duplicate
      @new_object = @object.dup
      if @new_object.save
        respond_to do |format|
          format.html {
            flash_success("#{klass_header} successfully duplicated!")
            redirect_to @klass
          }
          format.json { render json: @object.to_json(methods: [:to_label]) }
        end
      else
        flash_error("There was a problem creating the #{klass_header}.")
        redirect_to @klass
      end


    end

    def destroy
      # if it's not a 'permanent' object, destroy it
      if (!@object.respond_to?(:permanent) || !@object.permanent?) && @object.destroy
        respond_to do |format|
          format.html {
            flash_success("The #{klass_header} successfully deleted!")
            redirect_to @klass
          }
          format.json { render json: @object.to_json(methods: [:to_label]) }
        end
      else
        respond_to do |format|
          format.html {
            flash_error("Unable to delete the #{klass_header}")
            redirect_to @klass
          }
          format.json { render json: @object.to_json(methods: [:to_label]) }
        end
      end

    end


    private


      def set_klass
        # overwrite in your controller
        @klass = params[:class_name].constantize rescue nil
      end

      def set_header
        # optionally overwrite in your controllers
        @header = (@object ? object_header : klass_header.pluralize) rescue 'CMS'
      end

      def load_object
        # default lookup by ID
        # optionally overwrite in your controllers
        @object = @klass.admin_find(params[:id]) rescue nil
        render_404 unless @object
      end

      def object_header
        "#{@object.id ? 'Edit' : 'Create a New'} #{@object.class.admin_display_name}"
      end
      helper_method :object_header

      def klass_header
        @klass.admin_display_name.titleize
      end
      helper_method :klass_header

      def klass_params
        # overwrite in your controller
        params.require(@klass.model_name.param_key).permit(*@klass.admin_strong_params)
      end

  end
end
