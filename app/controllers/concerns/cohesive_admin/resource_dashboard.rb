module CohesiveAdmin::ResourceDashboard
	extend ActiveSupport::Concern
	
	included do
		before_action :set_model
		before_action :load_object, only:[:edit,:update,:destroy,:show,:clone]
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
	end
	
	def show
	end
	
	def new
	end
	
	def create
	end
	
	def edit
	end
	
	def update
	end
	
	def destroy
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
		sort_options = ['newest','oldest']
		sort_options << @model.admin_sort_column if @model.admin_sortable?

		params[:sort].downcase! if(params[:sort])
		params[:sort] = 'oldest' if !sort_options.include?(params[:sort])
		
		if(params[:sort] =~ /\A(old|new)est\z/i)
			order_field = :created_at
			direction   = { 'newest' => 'DESC', 'oldest' => 'ASC' }[params[:sort]]	
		else
			order_field = @model.admin_sort_column
		end
		
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
			@filter_object = @model.new(filter_params)
			
			if(params[:filter])
				@filter_args = {}
				@dashboard.strong_params.each do |p|
					filter_val = @filter_object.send(p)
					
					if(params[:filter][p] && (filter_val == false || !filter_val.blank?))
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
	
	def load_search_object
	end
	
	def controller_key
		params[:model_class].gsub('/','_')
	end
	
end