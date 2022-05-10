# frozen_string_literal: true

class ConsumerAuthRef < ApplicationRecord
  include Discard::Model

  KEYS = {
    sandbox_gateway_ref: 'sandbox_gateway_ref',
    sandbox_acg_oauth_ref: 'sandbox_acg_oauth_ref',
    sandbox_ccg_oauth_ref: 'sandbox_ccg_oauth_ref',
    prod_gateway_ref: 'prod_gateway_ref',
    prod_acg_oauth_ref: 'prod_acg_oauth_ref'
  }.freeze

  belongs_to :consumer

  validates :key, presence: true, acceptance: { accept: KEYS.values }
  validates :value, presence: true
end
