require "cohesive_admin/engine"
require "cohesive_admin/configuration"
require "cohesive_admin/amazon_signature"
require "turbolinks"

module CohesiveAdmin
  extend ActiveSupport::Autoload

  class << self
    attr_accessor :config
    attr_accessor :app_root

    def config
      self.config = Configuration.new unless @config
      @config
    end

    def manage(klass)
      if self.config.managed_models.select {|k| k.name == klass.name }.empty?
        self.config.managed_models << klass
      end
    end

    # If a project has multiple models configured for the CMS,
    # and the db doesn't exist or isn't migrated,
    # only display the log warning about it once.
    def db_is_not_connected
      unless @db_connection_warning
        @db_connection_warning = true
        unconnected_message = "CohesiveAdmin failed to initialize - no database connection available. Be sure to create your database, run the CohesiveAdmin generators, migrate your database, and try again."
        puts(unconnected_message)
        Rails.logger.error(unconnected_message)
      end
    end

  end

  def self.configure
    self.config ||= Configuration.new

    yield(self.config)

    after_configure
  end

  def self.after_configure

    # conveniences for AWS keys
    unless self.config.aws.blank?
      self.config.aws[:acl]               ||= 'public-read'
      self.config.aws[:key_start]         ||= 'cohesive_admin/'
      self.config.aws[:secret_access_key] ||= (self.config.aws[:credentials].credentials.secret_access_key rescue nil)
      self.config.aws[:access_key_id]     ||= (self.config.aws[:credentials].credentials.access_key_id rescue nil)
    end
  end

=begin

  The methods below are used to sort the models to work in the left hand navigation of the admin layout.

  @managed_models is set in the before_action which can be found in the CohesiveAdmin::ApplicationController

  It is set so the cohesive admin is always at the end of the list. We may want to set a way to configure this in the future. Maybe in an initializer??

=end

  def self.set_display_order

    set_display_order_value(get_highest_order_number)

    self.sort_managed_models!
    return self.config.managed_models
  end

  def self.get_highest_order_number
    highest_order_number = -1
    self.config.managed_models.each do |mm|
      if mm.admin_display_order != "unordered" && mm.admin_display_order > highest_order_number
        highest_order_number = mm.admin_display_order
      end
    end
    return highest_order_number
  end

  def self.set_display_order_value(highest_number)
    self.config.managed_models.each do |mm|
      if mm.model_name == "CohesiveAdmin::User"
        mm.display_order = highest_number + 2 #set the CohesiveAdmin::User to always be last
      elsif mm.admin_display_order == "unordered"
        mm.display_order = highest_number + 1
      else
        mm.display_order = mm.admin_display_order
      end
    end
  end

  def self.sort_managed_models!
    self.config.managed_models.sort! { |a,b| [a.display_order.to_i,a.admin_display_name.to_s] <=> [b.display_order.to_i, b.admin_display_name.to_s] }
  end

end
