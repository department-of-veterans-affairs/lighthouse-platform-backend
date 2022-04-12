# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Okta::BaseService do
  subject { Okta::BaseService.new }

  let(:request) { Struct.new(:last_name, :consumer) }
  let(:nested) { Struct.new(:organization) }

  let :user do
    request.new(
      'BonJovi',
      nested.new('Testing')
    )
  end

  describe 'has private methods' do
    it 'that build needed values' do
      allow(Oktakit::Client).to receive(:new).and_return(true)
      expect(subject.send(:consumer_name, user)).to eq('LPB-TestingBonJovi')
      expect(subject.send(:build_new_application_payload, user, application_type: 'web',
                                                                redirect_uri: 'example.com')).to include(:settings)
    end
  end
end
