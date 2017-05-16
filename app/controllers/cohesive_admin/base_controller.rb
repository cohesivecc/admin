require_dependency "cohesive_admin/application_controller"

module CohesiveAdmin
  class BaseController < ApplicationController


    before_action :set_klass
    before_action :set_header
		before_action :require_admin_config
    before_action :load_object, only: [:edit, :update, :destroy, :show, :clone]
    before_action :load_filter_object, only: [:index, :sort]
    before_action :load_search_object, only: [:index, :sort]
    before_action :load_list, only: [:index, :sort]

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

      render file: 'cohesive_admin/base/sort'
    end




    def apply_sort
      params[:item].each_with_index do |x, i|
        m = @klass.find(x)
        m.update_attribute(@klass.admin_sort_column, i)
      end
      render text: ''
    end





    def clone
      @object = @klass.new(@object.attributes)
      respond_to do |format|
        format.html { render file: 'cohesive_admin/base/form' }
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

			def require_admin_config
				render file: 'cohesive_admin/base/missing_admin_config' and return if @klass.admin_config[:error] == :missing_admin_config
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
        params.require(@klass.model_name.param_key).permit(*@klass.admin_strong_params)
      end


      def load_list
        # by default, use admin_sorted scope (see sortable)
        case params[:sort]
        when "newest"
          @skope = @klass.order("created_at DESC")
        when "oldest"
          @skope = @klass.order("created_at ASC")
        else
          @skope = @klass.admin_sorted
        end

        unless @filter_args.blank?
          # count of total objects (before applying filters)
          @items_total = @skope.count
          # apply any filters if necessary
          @skope = @skope.where(@filter_args)
          # now count them again
          @items_found = @skope.count
        end



        # @skope.where(valu)
        if params[:filter] && @klass.admin_searchable?
          @items_total = @skope.count
          clauses = []
          @klass.admin_config[:searchers].each do |search_field|
            clauses << @klass.arel_table[search_field[0].to_sym].matches("%#{params[:filter][:ca_search]}%").to_sql
          end
          @skope = @skope.where(clauses.join(' OR '))
          @items_found = @skope.count
        end

        # page == 'all' is set on the :sort action (via routes.rb), or in the Ajax call from the polymorphic input (polymorphic.coffee)
        @skope = @skope.page(params[:page]) unless params[:page] == 'all'

        @items = @skope.all
      end

      def filter_params
        params.fetch(:filter, {}).permit(*@klass.admin_strong_params)
      end

      def load_filter_object
        @filter_object = @klass.new(filter_params)


        if params[:filter]
          # filter out anything except allowed params, pluck them from our @filter_object
          @filter_args = {}

          @klass.admin_strong_params.each do |p|
            if params[:filter][p] && (@filter_object[p] == false || !@filter_object[p].blank?)
              @filter_args[p] = @filter_object.send(p)
            else
              # reset all searchable values to nil unless they're present in the search params (prevents default values when calling @klass.new)
              @filter_object.send("#{p}=", nil) rescue nil
            end
          end
        else
          # reset all searchable values to nil (prevents default values when calling @klass.new)
          @klass.admin_config[:filters].each do |k,v|
            @filter_object.send("#{k}=", nil)
          end
        end
      end

      def search_params
        params.fetch(:search, {}).permit(*@klass.admin_strong_params)
      end

      def load_search_object
        @search_object = @klass.new(search_params)
      end

  end
end
