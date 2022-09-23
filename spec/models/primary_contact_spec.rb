# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrimaryContact, type: :model do
  subject do
    PrimaryContact.new(
      email: 'email@acme.org',
      first_name: 'random',
      last_name: 'person',
      production_request_id: prod_request.id
    )
  end

  let(:prod_request) { ProductionRequest.create!(ProductionRequest.transform_params(production_request_params)) }
  let(:production_request_params) { build(:production_access_request) }

  describe 'tests an invalid PriamryContact model' do
    it "is invalid without an 'email'" do
      subject.email = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'first_name'" do
      subject.first_name = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'last_name'" do
      subject.last_name = nil
      expect(subject).not_to be_valid
    end
  end
end
