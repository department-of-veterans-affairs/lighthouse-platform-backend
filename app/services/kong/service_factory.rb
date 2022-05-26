# frozen_string_literal: true

module Kong
  class ServiceFactory
    def self.service(environment)
      return Kong::SandboxService.new if environment == :sandbox
      return Kong::ProductionService.new if environment == :production

      raise "Invalid environment: #{environment}"
    end
  end
end
