module CohesiveAdmin
	class Dashboard
		
		class Field
			
			attr_reader :model
			attr_reader :name, :type, :hint, :disabled, :placeholder
			
			# association attributes
			attr_reader :collection, :reflection, :nested
			
			# filterable and searchable field attributes
			attr_reader :filter, :searchable
			
			def initialize(attribute, model, type=nil)
				@model = model.name.underscore.sub("/", "_")
				@name = attribute
				
				if(type.is_a?(Hash))
					field_cfg = type.symbolize_keys
					type = field_cfg[:type]
				end
				
				@type = if(type.blank?)
									:string
								else
									type.to_sym
								end
				
				
				@hint					= field_cfg[:hint] || field_cfg[:help] if(field_cfg)
				@placeholder	= field_cfg[:placeholder] if(field_cfg)
				
				@disabled			= !field_cfg.nil? && %w{true disabled}.include?(field_cfg[:disabled].to_s)
				@filter  			= !field_cfg.nil? && field_cfg[:filter].to_s == 'true'
				@searchable		= !field_cfg.nil? && field_cfg[:searchable].to_s == 'true'	
				
				# use validations to determine if this should be a select box
				model.validators_on(attribute).each do |v| 
					if(v.kind == :inclusion && v.options[:in].is_a?(Array))
						@type = :select unless @type == :radio_buttons
						@collection = v.options[:in]
						break;
					end
				end unless @name.nil?
				
				# set up association attributes
        if(associated?)
          @reflection = model.reflections[attribute.to_s]
          @nested     = model.nested_attributes_options[attribute.to_sym]
        end	
			end
			
			def associated?
				%i{association polymorphic}.include?(type)
			end
			
			def simple?
				!associated?
			end
			
			def disabled?
				disabled
			end
			
			def filter?
				filter
			end
			
			def searchable?
				searchable
			end
			
			def nested?
				!@nested.nil?
			end
			
			def attachment?
				%i{refile shrine}.include?(type)
			end
			
			def text_searchable?
				%i{string email url tel text wysiwyg}.include?(type)
			end
			
			def label
				if(%w{id name created_at updated_at}.include?(@name.to_s))
					I18n.t("admin.fields.#{ @name }")
				else
					I18n.t("admin.fields.#{ @model }.#{ @name }")
				end
			end
			
			def value_for(object)
				return nil unless object.class.name.underscore.sub("/", "_") == @model
				if(@type == :refile)
					Refile.attachment_url(object, @name, :fill, 128, 96)
				elsif(@type == :shrine)
					object.send("#{@name}_url")
				elsif(@type == :boolean)
					object.send(@name) ? 'Yes' : 'No'
				else
					object.send(@name)
				end
			end
			
			def color_for(object)
				return '' unless object.class.name.underscore.sub("/", "_") == @model
				if(@type == :boolean)
					object.send(@name) ? 'green' : 'red'
				else
					'blue'
				end
			end
			
		end
		
		
		module Decoration
			extend ActiveSupport::Concern
			
			def plural_title
				I18n.t("admin.dashboards.#{ translation_key }", count:2)
			end
			alias_method :title, :plural_title
	
			def singular_title
				I18n.t("admin.dashboards.#{ translation_key }", count:1)
			end
			
			
			
			
			
			def form_fields
				@form_fields.keys
			end
			
			def form_field?(field)
				@form_fields.keys.include?(field)
			end
			
			def form_field_for(field)
				@form_fields[field]
			end
				
			def form_field_label(field)
				@form_fields[field].label
			end

			
			def filterable_fields
				@form_fields.select { |k,v| v.filter? }
			end
			
			def searchable_fields
				@form_fields.select { |k,v| v.searchable? }
			end
			
			
			def collection_fields
				@collection_fields.keys
			end
			
			def collection_field?(field)
				@collection_fields.keys.include?(field)
			end
			
			def collection_field_for(field)
				@collection_fields[field]
			end
			
			def collection_field_label(field=:label)
				
				return "" unless collection_field?(field)
				
				mapped_field = collection_field_for(field)
				
				fallbacks = []
				fallbacks << "admin.fields.#{ translation_key }.#{ mapped_field }".to_sym
				fallbacks << "admin.index.headers.#{ field }".to_sym
				fallbacks << field.to_s.capitalize
				
				I18n.t("admin.fields.#{ translation_key }.headers.#{ field }", default:fallbacks)
			end
			
		private
			
			def translation_key
				if(standalone?)
					id
				else
					@model.name.underscore.sub("/", "_")
				end
			end
			
			def model_field?(field)
				return false if standalone?
				@model.attribute_method?(field) || @model.method_defined?(field)
			end
			
		end
	end
end