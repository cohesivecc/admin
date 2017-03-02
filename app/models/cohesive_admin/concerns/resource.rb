module CohesiveAdmin::Concerns::Resource
  extend ActiveSupport::Concern

  included do
    # any required hooks here
  end

  def admin_resource?
    self.class.admin_resource?
  end

  module ClassMethods
    include CohesiveAdmin::Engine.routes.url_helpers

    def admin_resource?
      false
    end

    def admin_config
      @admin_config || parse_admin_config
    end

    def admin_fields
      @admin_fields || parse_admin_fields
    end

    def admin_display_name
      self.admin_config[:name] || self.name
    end

    def admin_find(id)
      send(admin_config[:finder], id)
    end

    def default_url_options
      ActionMailer::Base.default_url_options
    end

    def admin_attributes
      {
        class_name: self.name,
        display_name: self.admin_display_name,
        route_key: ActiveModel::Naming.route_key(self),
        uri: polymorphic_path(self, host: 'http://example.com')
      }
    end


    def display_name_method
      unless @display_name_method
        # admin_config['display_name_method'], self.name|self.to_label, or first admin_fields attribute, finally ID
        if (dn = self.admin_config[:display_name_method]) && (self.attribute_method?(dn) || self.method_defined?(dn))
          @display_name_method = dn
        elsif self.attribute_method?(:name) || self.method_defined?(:name)
          @display_name_method = :name
        else
          # iterate admin_fields until we find the first suitable attribute - NOT IDEAL!!
          self.admin_fields.each do |k,f|
            next if %w{association polymorphic}.include?(f[:type])
            break if (self.attribute_method?(k) || self.method_defined?(k)) && @display_name_method = k
          end
        end
        @display_name_method = :id if @display_name_method.blank?
      end
      @display_name_method
    end








    def admin_setup
      parse_admin_config
      parse_admin_fields
    end

    def parse_admin_config
      if self.admin_resource? && @admin_config.nil?
        ### @admin_config ###
        @admin_config = {
          name: self.name,
          finder: :find,
          fields: {},
          filters: {},
          sort: false,
          duplicate: false,
          order: Float::MAX
        }.merge(@admin_args.symbolize_keys)

        # attempt to parse config file
        # CohesiveAdmin configuration for a model can be placed in Rails.root/config/cohesive_admin/model_singular.yml
        fname = File.join('config', 'cohesive_admin', "#{ActiveModel::Naming.singular(self)}.yml")
        if File.exists?(CohesiveAdmin::Engine.root.join(fname))
          # CohesiveAdmin core models
          @admin_config.update( YAML.load_file(CohesiveAdmin::Engine.root.join(fname)).symbolize_keys )
        elsif File.exists?(CohesiveAdmin.app_root.join(fname))
          # user created models
          @admin_config.update( YAML.load_file(CohesiveAdmin.app_root.join(fname)).symbolize_keys )
        else
          # construct default config

          # reflections - ie. belongs_to, has_many
          self.reflections.each do |k, r|

            # omit has_one relationships by default, unless they are accepts_nested_attributes_for AND flagged as an admin_resource
            next if r.has_one? && (!self.nested_attributes_options.symbolize_keys.has_key?(k.to_sym) || !r.klass.admin_resource?)


            @admin_config[:fields][k.to_sym] = r.polymorphic? ? 'polymorphic' : 'association'
            # omit foreign key columns
            @blacklisted_columns << r.foreign_key.to_sym
            @blacklisted_columns << r.foreign_type.to_sym if r.polymorphic?
            # omit counter_cache columns
            @blacklisted_columns << (r.options[:counter_cache].blank? ? "#{r.name}_count" : r.options[:counter_cache].to_s).to_sym
          end

          self.columns.each do |c|
            @admin_config[:fields][c.name.to_sym] = {
              type: c.type
            } unless @blacklisted_columns.include?(c.name.to_sym)
          end if self.table_exists?
        end

        self.admin_sortable(@admin_config[:sort]) if @admin_config[:sort]
        self.admin_duplicatable(@admin_config[:duplicate]) if @admin_config[:duplicate]

        @admin_config
      else
        nil
      end
    end

    def parse_admin_fields
      if self.admin_resource? && self.admin_config
        ### @admin_fields ###
        @admin_fields = {}
        @admin_config[:fields].each do |k, field|
          attrs = {}
          if field.blank?
            attrs[:type] = :string
          elsif field.is_a?(String)
            attrs[:type] = field
          elsif field.is_a?(Hash)
            attrs = field.symbolize_keys
          end

          # selects
          self.validators_on(k).each do |v|
            if v.kind == :inclusion && v.options[:in].is_a?(Array)
              attrs[:type] = :select unless attrs[:type] == :radio_buttons
              attrs[:collection] = v.options[:in]
            end
          end

          if %w{association polymorphic}.include?(attrs[:type])
            r = self.reflections[k.to_s]
            attrs[:reflection] = r
            attrs[:nested] = self.nested_attributes_options[k.to_sym]
          end

          @admin_config[:filters][k] = attrs if field.is_a?(Hash) && field['filter']
          @admin_fields[k] = attrs
        end
        @admin_fields
      else
        nil
      end
    end

    def admin_strong_params
      unless @admin_strong_params
        # setup strong parameters from managed fields
        @admin_strong_params = []
        a = {}

        self.admin_fields.each do |k, f|

          if %w{association polymorphic}.include?(f[:type])
            r = f[:reflection]
            if f[:nested]
              a["#{k}_attributes".to_sym] = [:id] + r.klass.admin_strong_params
              a["#{k}_attributes".to_sym] << '_destroy' if f[:nested][:allow_destroy]

            elsif r.macro == :belongs_to
              @admin_strong_params << r.foreign_key
              @admin_strong_params << r.foreign_type.to_sym if r.polymorphic?
            elsif r.macro == :has_many || r.macro == :has_and_belongs_to_many
              @admin_strong_params << { :"#{r.name.to_s.singularize}_ids" => [] }
            end
          else
            @admin_strong_params << k

            # file deletion
            if %w{refile shrine}.include?(f[:type])
              @admin_strong_params << "remove_#{k}"
            end
          end
        end

        @admin_strong_params << a unless a.blank?
      end
      @admin_strong_params
    end

    def cohesive_admin(args={})

      @blacklisted_columns  = [:id, :created_at, :updated_at]
      @admin_args = args

      CohesiveAdmin.manage(self)

      class_eval do

        scope :admin_sorted, -> { order("created_at DESC") }

        # the attribute_method? function errors if the database hasn't been created or migrated yet.
        # this is a problem when including the CMS gem in Rails Application templates.
        #
        # Attempt to connect to the database.  If unable to connect, check for the presence of the to_label
        # function using public_instance_methods instead of attribute_method?
        connected = true
        begin
          self.connection unless self.connected?
        rescue
          connected = false
          CohesiveAdmin.db_is_not_connected
        end

        if (!connected && !self.public_instance_methods.include?(:to_label)) || (connected && !self.attribute_method?(:to_label))

          def to_label
            self.send(self.class.display_name_method)
          end

        end

        class << self

          def admin_resource?
            true
          end

        end # end class << self

      end

    end


  end # class methods

end
