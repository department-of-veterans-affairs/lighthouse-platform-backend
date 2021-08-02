# frozen_string_literal: true

class ConsumerApiAssignment < ApplicationRecord
  belongs_to :consumer
  belongs_to :api
end
