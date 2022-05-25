# frozen_string_literal: true
require 'date'

module Kong
  class DriftService
    def initialize(environment = nil)
      @env = environment
        @client = Kong::SandboxService
     end

    def pull_kong_consumers
      kong_consumers = @client.new.list_all_consumers
    end

    def time_sort
      pull_kong_consumers.filter do |consumer|
        consumer if consumer['created_at'] >= Date.yesterday.to_time.to_i
      end
    end
  end
end