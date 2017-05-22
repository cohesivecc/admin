module CohesiveAdmin
	
	class Configuration
	
		attr_accessor :namespace
		attr_accessor :default_sort_field
		attr_reader   :values
		
		def initialize
			@namespace = :admin
			@default_sort_field = :position
			
			@values = {}
			
			filename = File.join("config", "cohesive_admin.yml")
			load_paths = [
				CohesiveAdmin::Engine.root,
				Rails.root
			]
			
			load_paths.each do |path|
				config_file = path.join(filename)
				@values.update(YAML.load_file(config_file).symbolize_keys) if(File.exists?(config_file))
			end
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