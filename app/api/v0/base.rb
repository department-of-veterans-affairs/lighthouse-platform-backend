# frozen_string_literal: true

module V0
  class Base < Grape::API
    mount V0::Consumers
    mount V0::Environments
    mount V0::Providers
    mount V0::Support
  end
end
