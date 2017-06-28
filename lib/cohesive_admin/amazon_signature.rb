module CohesiveAdmin
  module AmazonSignature
    extend self

    def expiration
      if @expiry.blank? || Time.now >= @expiry
        @expiry = 10.hours.from_now
      else
        @expiry
      end
    end

    def signature
      Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest.new('sha1'),
            CohesiveAdmin.config.aws[:secret_access_key], self.policy
          )
        ).gsub("\n", "")
    end

    def policy
      Base64.encode64(self.policy_data.to_json).gsub("\n", "")
    end

    def policy_data
      {
        expiration: self.expiration.utc.iso8601,
        conditions: [
          ["starts-with", "$key", CohesiveAdmin.config.aws[:key_start]],
          ["starts-with", "$x-requested-with", "xhr"],
          ["content-length-range", 0, 20.megabytes],
          ["starts-with", "$content-type", ""],
          {bucket: CohesiveAdmin.config.aws[:bucket]},
          {acl: CohesiveAdmin.config.aws[:acl]},
          {success_action_status: "201"}
        ]
      }
    end

    def data_hash
      {:signature => self.signature, :policy => self.policy, :bucket => CohesiveAdmin.config.aws[:bucket], :acl => CohesiveAdmin.config.aws[:acl], :key_start => CohesiveAdmin.config.aws[:key_start], :access_key => CohesiveAdmin.config.aws[:access_key_id]}
    end
  end
end
