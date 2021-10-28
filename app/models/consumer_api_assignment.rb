# frozen_string_literal: true

class ConsumerApiAssignment < ApplicationRecord
  include Discard::Model

  belongs_to :consumer
  belongs_to :api
end
