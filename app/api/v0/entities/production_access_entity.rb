# frozen_string_literal: true

module V0
  module Entities
    class ProductionAccessEntity < Grape::Entity
      expose :primaryContact do
        expose :email
        expose :firstName
        expose :lastName
      end

      expose :secondaryContact do
        expose :email
        expose :firstName
        expose :lastName
      end

      expose :appName, if: lambda { |status, _options| status[:appName].present? }
      expose :apis
      expose :is508Compliant
      expose :organization
      expose :statusUpdateEmails

      expose :website, if: lambda { |status, _options| status[:website].present? }
    end
  end
end
