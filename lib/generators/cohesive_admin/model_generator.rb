require 'rails/generators/model_helpers'

module CohesiveAdmin
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      
      desc "This generator creates the default yml config file for an ActiveRecord model that implements cohesive_admin"
      def adminify
        
        # inject cohesive_admin into the model's class definition (if not already present)
        model_path = "app/models/#{ name }.rb"        
        content = File.binread(Rails.root.join(model_path))
        unless content =~ /\A[^#]+cohesive_admin/
          inject_into_class(model_path, name.camelize) do
            "\n  cohesive_admin\n"
          end
        end
        
        # generate the default yml file for the model, based on its attributes and associations.
        config_path = "config/cohesive_admin/#{ name }.yml"
        unless File.exists?(Rails.root.join(config_path))
          
          klass = name.singularize.classify.constantize
          blacklist = [:id, :created_at, :updated_at]

          fields = {}
					
					# refile attachments
					attachments = klass.ancestors.select { |a| a.to_s =~ /^Refile::Attachment/ }.collect { |a| a.to_s.gsub(/^Refile::Attachment\(|\)$/, '') }
					attachments.each do |a|
						fields[a] = 'refile'
						blacklist << "#{a}_id".to_sym
					end
					
          # reflections - ie. belongs_to, has_many
          klass.reflections.each do |k, r|
            # omit has_one relationships by default, unless they are accepts_nested_attributes_for AND flagged as an admin_resource
            next if r.has_one? && (!klass.nested_attributes_options.symbolize_keys.has_key?(k.to_sym) || !r.klass.admin_resource?)
      
						field_definition = {
							'type'	=> r.polymorphic? ? 'polymorphic' : 'association',
							'label'	=> k.pluralize.capitalize
						}
						
            fields[k.to_s] = field_definition
            
            # omit foreign key columns
            blacklist << r.foreign_key.to_sym
            blacklist << r.foreign_type.to_sym if r.polymorphic?
            
            # omit counter_cache columns
            blacklist << (r.options[:counter_cache].blank? ? "#{r.name}_count" : r.options[:counter_cache].to_s).to_sym
          end
          
          # standard columns / attributes
          klass.columns.each do |c|
            fields[c.name.to_s] = { 'type' => c.type.to_s, 'label' => c.name.capitalize } unless blacklist.include?(c.name.to_sym)
          end if klass.table_exists?
          
          yaml  = "# order: 1\n"
          yaml += "# sort: position\n"
					yaml += "# duplicate: true\n"
					yaml += { 'fields' => fields }.to_yaml.sub(/^\-{3}\n/, '')
          
          create_file Rails.root.join(config_path) do 
            yaml
          end
        end
      end
			
    end
  end
end


