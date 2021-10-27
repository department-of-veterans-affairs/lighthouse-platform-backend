# frozen_string_literal: true

class ConsumerApiAssignment < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :consumer
  belongs_to :api
end
