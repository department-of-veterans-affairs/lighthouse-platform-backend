# frozen_string_literal: true

module Okta
  class ServiceFactory
    def self.service(environment)
      return Okta::SandboxService.new if environment == :sandbox
      return Okta::ProductionService.new if environment == :production

      raise "Invalid environment: #{environment}"
    end
  end
end
