require_dependency "cohesive_admin/application_controller"

module CohesiveAdmin
  class ConfigController < ApplicationController
    
      # This method is how we transfer the config data from Ruby to our Javascript.
      # The CohesiveAdmin.coffee calls this URL via AJAX to initialize the front-end UI.
      def index
        # We can cache this JSON as long as the AmazonSignature doesn't expire
        # After that we need to refresh, otherwise S3 direct uploads will fail
        exp = CohesiveAdmin.config.aws.blank? ? 1.day.from_now : CohesiveAdmin::AmazonSignature.expiration
        cfg = Rails.cache.fetch('CohesiveAdmin.as_json', expires_in: (exp - Time.now)) do
          CohesiveAdmin.as_json
        end

        respond_to do |format|
          format.json { render json: cfg }
        end
      end

  end
end
