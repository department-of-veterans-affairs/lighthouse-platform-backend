# frozen_string_literal: true

module Kong
  class DriftService
    def initialize(environment = nil)
      @env = environment
        @client = Kong::SandboxService
     end

    def detect_drift
      kong_consumers = @client.new.list_all_consumers
      time_array = [].tap do |consumer_time|
        kong_consumers.each do |consumer|
          consumer_time << consumer['created_at']
        end
      end
      time_array.sort {|a,b| b <=> a}

    end
  end
end

#grab consumers from kong
#grab consumers from lcms
#take each consumers found and match them
#left over consumers added to lcms