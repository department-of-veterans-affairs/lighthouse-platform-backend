# frozen_string_literal: true

class ApiMetadatum < ApplicationRecord
  include Discard::Model

  belongs_to :api
  belongs_to :api_category
end
