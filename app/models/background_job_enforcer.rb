# frozen_string_literal: true

class BackgroundJobEnforcer < ApplicationRecord
  validates :job_type, :date, presence: true
end
