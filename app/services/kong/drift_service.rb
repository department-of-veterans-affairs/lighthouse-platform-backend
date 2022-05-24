# frozen_string_literal: true

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
      time_array = [].tap do |consumer_time|
        pull_kong_consumers.each do |consumer|
          consumer_time << consumer['created_at']
        end
      end
      time_array.sort {|a,b| b <=> a}
    end

    def last_20_consumers
      [].tap do |last_20_consumers|
        time_sort[0..19].each do |obj|
          last_20_consumers << obj
        end
      end
    end
  end
end