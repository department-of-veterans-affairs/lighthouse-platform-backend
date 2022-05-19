# frozen_string_literal: true

module Kong
  class DriftService
    def initialize(environment = nil)
      @env = environment
        @client = Kong::SandboxService
     end

    def detect_drift
      consumers = @client.new.list_all_consumers    
    end
  end
end