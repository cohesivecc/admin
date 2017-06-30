module CohesiveAdmin
  class Configuration
    DEFAULT_SETTINGS = {
      namespace: :admin,
      default_sort_field: :position
    }.freeze

    attr_accessor :namespace
    attr_accessor :default_sort_field
    attr_accessor :dashboards
    attr_accessor :aws
    attr_accessor :froala
    attr_accessor :authentication

    def initialize
      # set up defaults
      @namespace	= :admin
      @default_sort_field	= :position
      @dashboards	= {}.with_indifferent_access
      @aws	= {}.with_indifferent_access
      @froala	= nil
      @authentication	= CohesiveAdmin::Authentication

      load_model_config
      configure_aws

    end

    def [](path)
      parts = path.split('.')
      thing = send(parts.shift)
      thing = thing[parts.shift] until parts.empty?
      thing
    end

    private

    def load_model_config
      filename = File.join('config', 'cohesive_admin.yml')
      load_paths = [
        CohesiveAdmin::Engine.root,
        Rails.root
      ]

      @dashboards = {}.with_indifferent_access
      load_paths.each do |path|
        config_file = path.join(filename)
        if File.exist?(config_file)
          config_contents = YAML.load_file(config_file).deep_symbolize_keys!
          @dashboards.update(config_contents)
        end
      end
    end

    def configure_aws
      @aws.update(acl: 'public-read', key_start: 'cohesive_admin/')
      Rails.logger.info "LOGGING AWS: #{@aws}"
      # Rails.logger.info "LOGGING CONFIG: #{CohesiveAdmin.config.aws}"
    end

  end

  def self.config
    @configuration ||= Configuration.new
  end

  def self.config=(config)
    @configuration = config
  end

  def self.configure
    yield config
  end
end
