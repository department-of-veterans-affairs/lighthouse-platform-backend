# frozen_string_literal: true

require 'rails_helper'

describe V0::Reports, type: :request do
  before(:all) do
    ElasticsearchService.new.seed_elasticsearch
  rescue RuntimeError
    # assume valid state
  end

  describe 'reports api' do
    let(:user) { create(:user) }
    let(:consumer) { create(:consumer, :with_sandbox_ids, user: user) }

    it 'returns a successful first call' do
      get "/platform-backend/v0/reports/first-call/#{consumer[:id]}"
      expect(response.code).to eq('200')

      expect(response.body).to include('July 03, 2015')
    end
  end
end
