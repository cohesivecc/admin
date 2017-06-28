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
			@namespace					= :admin
			@default_sort_field	= :position
			@dashboards					= {}.with_indifferent_access
			@aws								= nil
			@froala							= nil
			@authentication			= CohesiveAdmin::Authentication
			
			load_model_config
		end
		
		def [](path)
			parts = path.split('.')
			thing = self.send(parts.shift)
			while(parts.length > 0)
				thing = thing[parts.shift]
			end
			thing
		end
		
	private
		
		def load_model_config
			filename = File.join("config", "cohesive_admin.yml")
			load_paths = [
				CohesiveAdmin::Engine.root,
				Rails.root
			]
			
			@dashboards = {}.with_indifferent_access
			load_paths.each do |path|
				config_file = path.join(filename)
				if(File.exists?(config_file))
					config_contents = YAML.load_file(config_file).deep_symbolize_keys!
					@dashboards.update(config_contents)
				end
			end
		end
	
	end
	
	def self.config
		@configuration ||= Configuration.new

		after_configure
	end
	
	def self.config=(config)
		@configuration = config
	end
	
	def self.configure
		yield config
	end

	def after_configure

		# conveniences for AWS keys
		unless self.config.aws.blank?
			self.config.aws[:acl]               ||= 'public-read'
			self.config.aws[:key_start]         ||= 'cohesive_admin/'
			self.config.aws[:secret_access_key] ||= (self.config.aws[:credentials].credentials.secret_access_key rescue nil)
			self.config.aws[:access_key_id]     ||= (self.config.aws[:credentials].credentials.access_key_id rescue nil)
		end
	end
	
end