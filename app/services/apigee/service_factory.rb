# frozen_string_literal: true

module Apigee
  class ServiceFactory
    def self.service(environment)
      return Apigee::SandboxService.new if environment == :sandbox
      return Apigee::ProductionService.new if environment == :production

      raise "Invalid environment: #{environment}"
    end
  end
end
