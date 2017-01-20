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

end
