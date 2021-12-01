# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConsumerApplySerializer do
  subject { ConsumerApplySerializer.render_as_hash(apply_params) }

  let :apply_params do
    {
      apis: 'claimsAttributes',
      email: 'jon@bon.jovi',
      firstName: 'Jon',
      lastName: 'Bon Jovi',
      organization: '80s Hair Company',
      termsOfService: true,
      kong_id: 't3st-1d-4-us3r',
      kongUsername: 'kingKong',
      token: '4pi-k3y'
    }
  end

  describe 'handles serializing response for developer portal' do
    it { expect(subject[:email]).to eq('jon@bon.jovi') }
    it { expect(subject[:token]).to eq('4pi-k3y') }
    it { expect(subject[:firstName]).to eq(nil) }
  end
end
