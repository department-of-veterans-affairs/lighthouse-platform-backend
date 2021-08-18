# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserService do
  let(:subject) { UserService.new }
  let(:okta_ref) { '0kt4-rul3s' }
  let(:gateway_ref) { 'l3g1t-1d' }
  let :consumer do
    {
      'firstName' => 'Bruce',
      'lastName' => 'Wayne',
      'description' => 'Not batman.',
      'organization' => 'Wayne Enterprises'
    }
  end

  describe 'constructs a user' do
    it 'and builds the necessary user object for creation' do
      result = subject.construct_import(consumer, gateway_ref, okta_ref)
      expect(result[:user][:first_name]).to eq('Bruce')
      expect(result[:user][:consumer_attributes][:organization]).to eq('Wayne Enterprises')
      expect(result[:user][:consumer_attributes][:sandbox_oauth_ref]).to eq(okta_ref)
    end
  end
end
