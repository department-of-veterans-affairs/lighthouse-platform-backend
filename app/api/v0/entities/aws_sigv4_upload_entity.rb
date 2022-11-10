# frozen_string_literal: true

module V0
  module Entities
    class AwsSigv4UploadEntity < Grape::Entity
      expose :acl, documentation: { type: String }
      expose :bucket_name, documentation: { type: String }
      expose :content_type, documentation: { type: String }
      expose :key, documentation: { type: String }
      expose :logoUrls, documentation: { is_array: true }
      expose :policy, documentation: { type: String }
      expose :resizeTriggerUrls, documentation: { is_array: true }
      expose :s3_region_endpoint, documentation: { type: String }
      expose :x_amz_algorithm, documentation: { type: String }
      expose :x_amz_credential, documentation: { type: String }
      expose :x_amz_date, documentation: { type: String }
      expose :x_amz_expires, documentation: { type: String }
      expose :x_amz_security_token, documentation: { type: String }
      expose :x_amz_signature, documentation: { type: String }
    end
  end
end
