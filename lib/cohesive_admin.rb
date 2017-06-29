require 'simple_form'
require 'compass-rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'materialize-sass'

require "cohesive_admin/configuration"
require "cohesive_admin/routing"
require "cohesive_admin/dashboard"
require "cohesive_admin/engine"
require "cohesive_admin/amazon_signature"

module CohesiveAdmin

	def self.namespace
		Rails.application.routes.named_routes[:cohesive_admin].path.source.sub("\\A/", "").to_sym
	end

	@@router = nil
	def self.routing
		@@router ||= CohesiveAdmin::Routing.new
	end


	def self.as_json(options={})
		# pass CohesiveAdmin config settings down to Javascript
		js_config = {
			managed_models: CohesiveAdmin::Dashboard.all.map(&:model_config).compact,
			aws: nil,
			froala: { key:(config.froala[:key] rescue nil) },
			mount_point: "/#{ namespace }"
		}

    # AWS settings
    unless self.config.aws.blank?
      # Froala requires that we provide the region-specific endpoint as the 'region' parameter. We'll use the aws-sdk gem to provide this.
      bucket = Aws::S3::Bucket.new(self.config.aws[:bucket], { region: self.config.aws[:region] })
      region = bucket.client.config.endpoint.host.gsub(/\.amazonaws\.com\Z/, '')

          # acl: 'public-read',
          # key_start: 'cohesive_admin/'
          # key_start:      self.config.aws[:key_start],
          # acl:            self.config.aws[:acl],
      js_config[:aws] = {
          bucket:         self.config.aws[:bucket],
          region:         region,
          acl: 'public-read',
          key_start: 'cohesive_admin/',
          access_key_id:  self.config.aws[:access_key_id],
          policy:         AmazonSignature.policy,
          signature:      AmazonSignature.signature,
          assets:         {
                            index:      Engine.routes.url_helpers.s3_assets_path,
                            delete:     Engine.routes.url_helpers.delete_s3_assets_path,
                            preloader:  ActionController::Base.helpers.asset_path('cohesive_admin/preloader.gif')
                          }
      }
    end

		js_config
	end

end
