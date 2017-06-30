module CohesiveAdmin::ResourceDashboard
	extend ActiveSupport::Concern

	included do
		before_action :set_model
		before_action :load_object, only:[:edit,:update,:destroy,:show,:duplicate]
		before_action :load_filter_object, only:[:index,:sort]
		before_action :load_search_object, only:[:index,:sort]
		before_action :load_collection, only:[:index,:sort]

    # Force the classes to use the primary key as the to_param within our CMS
    # This addresses the scenario where the to_param fields can be manipulated in CMS,
    # creating a condition whereby the finder method can't find the object to update it because it has changed.
    #
    # Best practice: all your cohesive_admin models should have the 'id' column as the primary key -
    # regardless of what is used as to_param on the front-end of your site.
    around_action do |controller, action|
      @model.class_eval do
        alias :__cohesive_admin_to_param :to_param
        def to_param() send(self.class.primary_key).to_s end
      end

      begin
        action.call
      ensure
        @model.class_eval do
          alias :to_param :__cohesive_admin_to_param
        end
      end
    end

	end

	def index
		respond_to do |format|
			format.html { render file: 'cohesive_admin/resource/index' }
			format.json { render json: @collection.to_json(methods: [:to_label]) }
		end
	end

	def show
	end

	def new
		@object = @model.new
    respond_to do |format|
      format.html { render file: 'cohesive_admin/resource/form' }
    end
	end

	def create

		@object = @model.new(model_params)

		if(params[:duplicate_of].present?)
			if(original_object = @model.find(params[:duplicate_of]))
				# if duplicating an object, duplicate its attachments if new ones were not uploaded.
				@dashboard.config[:fields].each { |field,cfg|

					field_type =	if(cfg.is_a?(Hash))
													cfg[:type]
												elsif(cfg.is_a?(String))
													cfg
												end

					next unless %w{refile shrine}.include?(field_type)

					# If the field is a refile attachment and the attachment is present
					# on the original object, but a new attachment wasn't uploaded for the duplicate
					if(field_type == "refile" && !original_object.send(field).nil? && @object.send(field).nil?)
						# copy the image in the refile store and assign its id to the duplicate object.
						copied_image = Refile.backends["store"].upload(original_object.send(field).download)
						@object.send(:"#{ field }_id=", copied_image.id)
					elsif(field_type == "shrine")
						# TODO: handle shrine
					end
				}
			end
		end

		ok = @object.save

		flash_status = ok ? :success : :error
		flash_msg(
			t("admin.create.#{ flash_status }", model:@dashboard.singular_title),
			status: flash_status
		)

		respond_to do |format|
			format.html {
				if(ok)
					redirect_to polymorphic_path(@dashboard.path)
				else
					render file:'cohesive_admin/resource/form'
				end
			}
			format.json { render json: @object.to_json(methods:[:to_label]) }
		end
	end

	def edit
    respond_to do |format|
      format.html { render file: 'cohesive_admin/resource/form' }
    end
	end

	def update
		ok = @object.update(model_params)

		flash_status = ok ? :success : :error
		flash_msg(
			t("admin.update.#{ flash_status }", model:@dashboard.singular_title),
			status:flash_status
		)

		respond_to do |format|
			format.html {
				if(ok)
					redirect_to polymorphic_path(@dashboard.path)
				else
					render file: 'cohesive_admin/resource/form'
				end
			}
			format.json { render json:@object.to_json(methods:[:to_label]) }
		end
	end

	def destroy

		descriptor = "with id #{ @object.id }"

		# if it's not a 'permanent' object, destroy it
		ok = (!@object.respond_to?(:permanent?) || !@object.permanent?) && @object.destroy

    label_field = @dashboard.collection_fields[:label]
    label = label_field.value_for(@object)
		descriptor = "with #{ label_field.label } '#{ label }'" if label.is_a?(String)

		flash_status = ok ? :success : :error
		flash_msg(
			t("admin.destroy.#{ flash_status }", model:@dashboard.singular_title, descriptor:descriptor),
			status: flash_status
		)

		respond_to do |format|
			format.html {
				redirect_to polymorphic_path(@dashboard.path)
			}
			format.json { render json:@object.to_json(methods:[:to_label]) }
		end
	end

	def duplicate
		render_404 and return unless @model.admin_duplicatable?
		@object = @model.new(@object.attributes)
		respond_to do |format|
			format.html { render file: 'cohesive_admin/resource/form' }
		end
	end

	def sort
		render_404 and return unless @model.admin_sortable?
		render file: 'cohesive_admin/resource/sort'
	end

	def apply_sort
		render_404 and return unless @model.admin_sortable?
		params[:item].each_with_index do |x, i|
      m = @model.find(x)
      m.update_attribute(@model.admin_sort_column, i)
    end
    render text: ''
	end

	class_methods do

		def cohesive_admin_type
			:resource_dashboard
		end

	end

	private

	def set_model
		@model = @dashboard.model
	end

	def load_object
		@object = @model.find(params[:id]) rescue nil
	end


	def load_collection

		# 1. Determine the scope's sort order
		unless(params[:action] == 'sort')
			sort_options = ['newest','oldest']
			sort_options << @model.admin_sort_column if @model.admin_sortable?

			params[:sort].downcase! if(params[:sort])
			params[:sort] = 'oldest' if !sort_options.include?(params[:sort])

			if(params[:sort] =~ /\A(old|new)est\z/i)
				order_field = :created_at
				direction   = { 'newest' => 'DESC', 'oldest' => 'ASC' }[params[:sort]]
			end
		end

		order_field ||= @model.admin_sort_column
		direction   ||= 'ASC'

		@skope = @model.order([order_field, direction].compact.join(' '))

		# 2. Filter the results (if filter options are present)
		unless(@filter_args.blank?)

			# remove the search text from the filters. handle it separately later
			search_string = @filter_args.delete(:ca_search)

			@items_total = @skope.count
			@skope = @skope.where(@filter_args)

			# handle search text
			if(search_string && @model.admin_searchable?)
				clauses = []
				@dashboard.searchable_fields.each do |k,field|
					clauses << @model.arel_table[field.name].matches("%#{ params[:filter][:ca_search] }%").to_sql if(field.text_searchable?)
				end
				@skope = @skope.where(clauses.join(' OR '))
			end

			@items_found = @skope.count
		end

		@skope = @skope.page(params[:page]) unless(params[:page] == 'all')
		@collection = @skope.all
	end


	def load_filter_object

		unless @dashboard.filterable_fields.empty?

			filter_params = params.fetch(:filter, {}).permit(@dashboard.strong_params)
			search_param  = filter_params.delete(:ca_search)

			@filter_object = @model.new(filter_params)
			@filter_object.ca_search = search_param if @filter_object.respond_to?(:ca_search)

			if(params[:filter])
				@filter_args = {}
				@dashboard.strong_params.each do |p|

					filter_val = @filter_object.send(p) unless p == :ca_search || p.is_a?(Hash)

					if(p == :ca_search)
						@filter_args[p] = filter_params[:ca_search]
					elsif(params[:filter][p] && (filter_val == false || !filter_val.blank?))
						@filter_args[p] = filter_val
					else
						@filter_object.send("#{p}=", nil) rescue nil
					end
				end
			else
				@dashboard.filterable_fields.each do |k,v|
					@filter_object.send("#{k}=", nil) rescue nil
				end
			end
		end
	end

	def search_params
		params.fetch(:search, {}).permit(*@dashboard.strong_params)
	end

	def load_search_object
		@search_object = @model.new(search_params)
	end

	def controller_key
		params[:model_class].gsub('/','_')
	end

	def model_params
		params.require(@model.model_name.param_key).permit(*@dashboard.strong_params)
	end

end
