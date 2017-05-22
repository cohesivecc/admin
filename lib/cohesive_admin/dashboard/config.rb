module CohesiveAdmin
	class Dashboard
		module Config
			extend ActiveSupport::Concern
			
		#private
		
			def load_config
				config_key = id.to_sym
				@config = CohesiveAdmin.config.values[config_key].clone.with_indifferent_access rescue {} if(CohesiveAdmin.config.values.has_key?(config_key))
				@config ||= default_config
				@config[:headings] ||= {}
				@config[:order] ||= CohesiveAdmin.config.values.keys.index(config_key)
				
				load_field_config unless standalone?
			end
			
			def default_config
				if(standalone?)
					default_standalone_config
				else
					default_model_config
				end
			end
	
			def default_standalone_config
				{}
			end
	
			def default_model_config
				return {} if @model.nil? || !@model.table_exists?
		
				blacklist = [:id, :created_at, :updated_at]
				cfg = { fields:{} }
		
				# detect refile attachments
				attachments = @model.ancestors.select { |a| a.to_s =~ /^Refile::Attachment/ }.collect { |a| a.to_s.gsub(/^Refile::Attachment\(|\)$/, '') }
				attachments.each do |a|
					cfg[:fields][a.to_sym] = 'refile'
					blacklist << "#{a}_id".to_sym
				end
		
				# detect reflects (belongs_to, has_many, etc)
		    @model.reflections.each do |k, r|
		      # omit has_one relationships by default, unless they are accepts_nested_attributes_for AND flagged as an admin_model
		      next if r.has_one? && (!@model.nested_attributes_options.symbolize_keys.has_key?(k.to_sym) || !r.klass.admin_model?)
			
		      cfg[:fields][k.to_sym] = r.polymorphic? ? 'polymorphic' : 'association'
      
		      # omit foreign key columns
		      blacklist << r.foreign_key.to_sym
		      blacklist << r.foreign_type.to_sym if r.polymorphic?
      
		      # omit counter_cache columns
		      blacklist << (r.options[:counter_cache].blank? ? "#{r.name}_count" : r.options[:counter_cache].to_s).to_sym
		    end
		
				# detect standard columns/attributes, ignoring ones in the blacklist
		    @model.columns.each do |c|
		      cfg[:fields][c.name.to_sym] = c.type.to_s unless blacklist.include?(c.name.to_sym)
		    end if @model.table_exists?
		
				cfg.with_indifferent_access
		
			end
			
			
			
			def load_field_config
				return nil if @model.nil? || !@model.table_exists?
				
				@collection_fields = {}.with_indifferent_access
				@form_fields = {}.with_indifferent_access
				
				fallback_thumb_field = nil
				fallback_label_field = nil
				
				config[:fields].each do |field, type|
					@form_fields[field] = Field.new(field, @model, type)
					fallback_thumb_field ||= field if %w{refile shrine}.include?(type)
					fallback_label_field ||= field unless %w{refile shrine association polymorphic}.include?(type)
				end
				
				
				config[:headings][:thumbnail] ||= fallback_thumb_field if fallback_thumb_field
				config[:headings][:label] ||= fallback_label_field || :id
				config[:headings][:date]  ||= :created_at
				config[:headings].each do |heading, field|
					@collection_fields[heading] = @form_fields[field] || Field.new(field, @model)
				end
			end
			
		end
	end
end