# frozen_string_literal: true

module V0
  module Entities
    class AwsSigv4UploadEntity < Grape::Entity
      expose :acl, documentation: { type: String }
      expose :bucketName, documentation: { type: String }
      expose :contentType, documentation: { type: String }
      expose :key, documentation: { type: String }
      expose :logoUrls, documentation: { is_array: true }
      expose :policy, documentation: { type: String }
      expose :resizeTriggerUrls, documentation: { is_array: true }
      expose :s3RegionEndpoint, documentation: { type: String }
      expose :xAmzAlgorithm, documentation: { type: String }
      expose :xAmzCredential, documentation: { type: String }
      expose :xAmzDate, documentation: { type: String }
      expose :xAmzExpires, documentation: { type: String }
      expose :xAmzSecurityToken, documentation: { type: String }
      expose :xAmzSignature, documentation: { type: String }
    end
  end
end
